import Testing
import UIKit
@testable import stickers

struct WebPEncodingTests {

    @Test func encodes512x512AndDecodesBackAsWebP() throws {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        let image = UIGraphicsImageRenderer(size: CGSize(width: 512, height: 512), format: format).image { ctx in
            UIColor.red.setFill()
            ctx.fill(CGRect(x: 0, y: 0, width: 256, height: 512))
        }

        let data = try LibWebPEncoder().encode(image, quality: 80)

        #expect(data.prefix(4) == Data("RIFF".utf8))
        #expect(data.dropFirst(8).prefix(4) == Data("WEBP".utf8))

        let decoded = try #require(UIImage(data: data)?.cgImage)
        #expect(decoded.width == 512)
        #expect(decoded.height == 512)
    }
}
