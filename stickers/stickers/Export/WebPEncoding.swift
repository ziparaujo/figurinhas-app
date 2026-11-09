import UIKit
import WebP

protocol WebPEncoding {
    /// Codifica a imagem em WebP preservando a transparência. `quality` vai de 0 a 100.
    func encode(_ image: UIImage, quality: Float) throws -> Data
}

struct LibWebPEncoder: WebPEncoding {
    func encode(_ image: UIImage, quality: Float) throws -> Data {
        let config = WebPEncoderConfig.preset(.picture, quality: quality)
        return try WebPEncoder().encode(image, config: config)
    }
}
