import SwiftUI

@Observable
@MainActor
final class StickerEditorState {
    static let zoomRange: ClosedRange<CGFloat> = 0.2...8
    static let textScaleRange: ClosedRange<CGFloat> = 0.4...3
    /// Área aproximada de toque do texto, em pontos do canvas, com `textScale == 1`.
    static let textHitSize = CGSize(width: 400, height: 140)

    var photo: UIImage?
    var photoOffset: CGSize = .zero
    var photoZoom: CGFloat = 1
    var text = ""
    var textPosition = StickerCanvasView.defaultTextPosition
    var textScale: CGFloat = 1

    var canSave: Bool { photo != nil }

    var canvas: StickerCanvasView {
        StickerCanvasView(photo: photo, photoOffset: photoOffset, photoZoom: photoZoom,
                          text: text, textPosition: textPosition, textScale: textScale)
    }

    func setText(position: CGPoint) {
        textPosition = Self.clamp(position)
    }

    func setZoom(_ zoom: CGFloat) {
        photoZoom = min(max(zoom, Self.zoomRange.lowerBound), Self.zoomRange.upperBound)
    }

    func setTextScale(_ scale: CGFloat) {
        textScale = min(max(scale, Self.textScaleRange.lowerBound), Self.textScaleRange.upperBound)
    }

    /// Retângulo de toque do texto, em pontos do canvas, acompanhando a escala.
    var textHitRect: CGRect {
        let size = CGSize(width: Self.textHitSize.width * textScale, height: Self.textHitSize.height * textScale)
        return CGRect(x: textPosition.x - size.width / 2, y: textPosition.y - size.height / 2,
                      width: size.width, height: size.height)
    }

    /// `point` em pontos do canvas. Sem texto, nunca acerta.
    func isOnText(_ point: CGPoint) -> Bool {
        !text.isEmpty && textHitRect.contains(point)
    }

    /// Mantém o centro do texto dentro do canvas.
    static func clamp(_ point: CGPoint) -> CGPoint {
        CGPoint(x: min(max(point.x, 0), StickerCanvasView.side),
                y: min(max(point.y, 0), StickerCanvasView.side))
    }
}
