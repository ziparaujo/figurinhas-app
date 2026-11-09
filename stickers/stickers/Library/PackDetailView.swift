import SwiftUI
import SwiftData

struct PackDetailView: View {
    @Environment(\.modelContext) private var context
    let pack: StickerPack
    @State private var showingEditor = false
    @State private var sendError: String?

    private var library: PackLibrary { PackLibrary(context: context, files: .default) }
    private var missingStickers: Int { max(0, StickerPackExporter.minStickers - pack.stickers.count) }

    private func sendToWhatsApp() {
        let exporter = StickerPackExporter(encoder: LibWebPEncoder(), files: .default)
        do {
            try WhatsAppSender.live.send(pack, using: exporter)
        } catch {
            sendError = error.localizedDescription
        }
    }

    private let columns = [GridItem(.adaptive(minimum: 90), spacing: 12)]

    var body: some View {
        ScrollView {
            if pack.stickers.isEmpty {
                ContentUnavailableView("Pacote vazio", systemImage: "photo.on.rectangle",
                                       description: Text("Adicione a primeira figurinha."))
            } else {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(pack.sortedStickers) { sticker in
                        StickerThumbnail(sticker: sticker)
                            .contextMenu {
                                Button("Remover", systemImage: "trash", role: .destructive) { library.remove(sticker) }
                            }
                    }
                }
                .padding()
            }
        }
        .navigationTitle(pack.name)
        .toolbar {
            Button("Nova figurinha", systemImage: "plus") { showingEditor = true }
            .disabled(!PackLibrary.canAddSticker(to: pack))
        }
        .alert("Não foi possível adicionar", isPresented: Binding(
            get: { sendError != nil }, set: { if !$0 { sendError = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(sendError ?? "")
        }
        .sheet(isPresented: $showingEditor) { StickerEditorView(pack: pack) }
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 8) {
                if !PackLibrary.canAddSticker(to: pack) {
                    Text("Este pacote já tem \(PackLibrary.maxStickersPerPack) figurinhas, o máximo permitido.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                Button("Adicionar ao WhatsApp", action: sendToWhatsApp)
                    .buttonStyle(.borderedProminent)
                    .disabled(missingStickers > 0)
                if missingStickers > 0 {
                    Text("Faltam \(missingStickers) figurinhas para enviar (mínimo \(StickerPackExporter.minStickers)).")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }
            .padding()
        }
    }
}

private struct StickerThumbnail: View {
    let sticker: Sticker

    var body: some View {
        Group {
            if let data = try? StickerFileStore.default.read(sticker.fileName), let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFit()
            } else {
                Image(systemName: "exclamationmark.triangle").foregroundStyle(.secondary)
            }
        }
        .frame(width: 90, height: 90)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}
