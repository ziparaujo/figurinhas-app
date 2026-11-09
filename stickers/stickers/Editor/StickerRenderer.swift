import SwiftUI

enum StickerRenderer {
    /// Renderiza o canvas a `scale = 1`, saindo em 512x512 pixels independente da tela.
    @MainActor
    static func render(_ canvas: StickerCanvasView) -> UIImage? {
        let renderer = ImageRenderer(content: canvas)
        renderer.scale = 1
        renderer.isOpaque = false
        return renderer.uiImage
    }
}
