import SwiftUI
import SwiftData
import PhotosUI

struct StickerEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context
    let pack: StickerPack

    @State private var state = StickerEditorState()
    @State private var pickerItem: PhotosPickerItem?
    @State private var baseOffset: CGSize = .zero
    @State private var baseZoom: CGFloat = 1
    @State private var baseTextScale: CGFloat = 1
    @State private var pinchTarget: PinchTarget?
    @State private var baseTextPosition: CGPoint = StickerCanvasView.defaultTextPosition
    @State private var errorMessage: String?

    /// Quem recebe a pinça atual; decidido no início do gesto e mantido até o fim.
    private enum PinchTarget { case text, photo }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                GeometryReader { geo in
                    let side = min(geo.size.width, geo.size.height)
                    canvas(scale: side / StickerCanvasView.side)
                        .frame(width: side, height: side)
                        .frame(maxWidth: .infinity)
                }
                .aspectRatio(1, contentMode: .fit)

                PhotosPicker(selection: $pickerItem, matching: .images) {
                    Label(state.photo == nil ? "Escolher foto" : "Trocar foto", systemImage: "photo")
                }
                TextField("Texto (opcional)", text: $state.text)
                    .textFieldStyle(.roundedBorder)
                Spacer()
            }
            .padding()
            .navigationTitle("Nova figurinha")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancelar") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Salvar", action: save).disabled(!state.canSave)
                }
            }
            .onChange(of: pickerItem) { _, item in loadPhoto(item) }
            .alert("Não foi possível salvar", isPresented: Binding(
                get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "")
            }
        }
    }

    private func canvas(scale: CGFloat) -> some View {
        state.canvas
            .overlay {
                if !state.text.isEmpty {
                    Color.clear
                        .frame(width: state.textHitRect.width, height: state.textHitRect.height)
                        .contentShape(Rectangle())
                        .position(state.textPosition)
                        .highPriorityGesture(textDrag(scale: scale))
                }
            }
            .background(Color.gray.opacity(0.2))
            .gesture(photoDrag(scale: scale))
            .simultaneousGesture(pinch)
            .scaleEffect(scale)
    }

    // O deslocamento vem em pontos de tela (espaço global); divide pela escala para virar pontos do canvas.
    private func photoDrag(scale: CGFloat) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                state.photoOffset = CGSize(width: baseOffset.width + value.translation.width / scale,
                                           height: baseOffset.height + value.translation.height / scale)
            }
            .onEnded { _ in baseOffset = state.photoOffset }
    }

    // `startLocation` é o ponto central dos dedos no espaço local do canvas (512 pt, pois o gesto vem antes do scaleEffect).
    private var pinch: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                if pinchTarget == nil {
                    pinchTarget = state.isOnText(value.startLocation) ? .text : .photo
                }
                switch pinchTarget {
                case .text: state.setTextScale(baseTextScale * value.magnification)
                default: state.setZoom(baseZoom * value.magnification)
                }
            }
            .onEnded { _ in
                switch pinchTarget {
                case .text: baseTextScale = state.textScale
                default: baseZoom = state.photoZoom
                }
                pinchTarget = nil
            }
    }

    private func textDrag(scale: CGFloat) -> some Gesture {
        DragGesture(coordinateSpace: .global)
            .onChanged { value in
                state.setText(position: CGPoint(x: baseTextPosition.x + value.translation.width / scale,
                                                y: baseTextPosition.y + value.translation.height / scale))
            }
            .onEnded { _ in baseTextPosition = state.textPosition }
    }

    private func loadPhoto(_ item: PhotosPickerItem?) {
        guard let item else { return }
        Task {
            guard let data = try? await item.loadTransferable(type: Data.self),
                  let image = PhotoLoader.downsampled(data) else {
                errorMessage = "Não foi possível abrir a foto escolhida."
                return
            }
            state.photo = image
            state.photoOffset = .zero
            state.setZoom(1)
            baseOffset = .zero
            baseZoom = 1
        }
    }

    private func save() {
        guard state.canSave else { return }
        guard let png = StickerRenderer.render(state.canvas)?.pngData() else {
            errorMessage = "Não foi possível gerar a imagem da figurinha."
            return
        }
        do {
            try PackLibrary(context: context, files: .default).addSticker(png: png, to: pack)
            dismiss()
        } catch PackLibraryError.packFull {
            errorMessage = "Este pacote já tem \(PackLibrary.maxStickersPerPack) figurinhas, o máximo permitido."
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
