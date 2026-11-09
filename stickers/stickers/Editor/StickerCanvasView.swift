import SwiftUI

/// Canvas lógico de 512x512 pt usado pelo editor (exibido com `scaleEffect`) e pela renderização final.
struct StickerCanvasView: View {
    static let side: CGFloat = 512

    var photo: UIImage?
    var photoOffset: CGSize = .zero
    var photoZoom: CGFloat = 1
    var text: String = ""
    var textPosition: CGPoint = StickerCanvasView.defaultTextPosition

    static let defaultTextPosition = CGPoint(x: side / 2, y: side * 0.86)

    var body: some View {
        ZStack {
            if let photo {
                Image(uiImage: photo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: Self.side, height: Self.side)
                    .scaleEffect(photoZoom)
                    .offset(photoOffset)
            }
            if !text.isEmpty {
                OutlinedText(text: text).position(textPosition)
            }
        }
        .frame(width: Self.side, height: Self.side)
        .clipped()
    }
}

/// Texto branco e grosso com contorno preto, feito de cópias deslocadas (o SwiftUI não tem stroke em `Text`).
struct OutlinedText: View {
    static let fontSize: CGFloat = 72
    static let outlineCopies = 16
    static let outlineRadius = 0.06 * fontSize

    let text: String

    var body: some View {
        ZStack {
            ForEach(0..<Self.outlineCopies, id: \.self) { index in
                let angle = Double(index) / Double(Self.outlineCopies) * 2 * .pi
                label
                    .foregroundStyle(.black)
                    .offset(x: cos(angle) * Self.outlineRadius, y: sin(angle) * Self.outlineRadius)
            }
            label.foregroundStyle(.white)
        }
    }

    private var label: some View {
        Text(text)
            .font(.system(size: Self.fontSize, weight: .black))
            .multilineTextAlignment(.center)
            .lineLimit(2)
            .minimumScaleFactor(0.3)
            .frame(maxWidth: StickerCanvasView.side * 0.9)
    }
}
