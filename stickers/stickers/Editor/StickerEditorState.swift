import SwiftUI

@Observable
@MainActor
final class StickerEditorState {
    static let zoomRange: ClosedRange<CGFloat> = 0.2...8

    var photo: UIImage?
    var photoOffset: CGSize = .zero
    var photoZoom: CGFloat = 1
    var text = ""
    var textPosition = StickerCanvasView.defaultTextPosition

    var canSave: Bool { photo != nil }

    var canvas: StickerCanvasView {
        StickerCanvasView(photo: photo, photoOffset: photoOffset, photoZoom: photoZoom,
                          text: text, textPosition: textPosition)
    }

    func setText(position: CGPoint) {
        textPosition = Self.clamp(position)
    }

    func setZoom(_ zoom: CGFloat) {
        photoZoom = min(max(zoom, Self.zoomRange.lowerBound), Self.zoomRange.upperBound)
    }

    /// Mantém o centro do texto dentro do canvas.
    static func clamp(_ point: CGPoint) -> CGPoint {
        CGPoint(x: min(max(point.x, 0), StickerCanvasView.side),
                y: min(max(point.y, 0), StickerCanvasView.side))
    }
}
