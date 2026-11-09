import UIKit

enum ExportError: LocalizedError, Equatable {
    case tooFewStickers(missing: Int)
    case tooManyStickers
    case invalidEmojiCount(sticker: Int)
    case textTooLong
    case unreadableSticker(sticker: Int)
    case stickerTooLarge(sticker: Int)
    case trayTooLarge

    var errorDescription: String? {
        switch self {
        case .tooFewStickers(let missing): "Faltam \(missing) figurinhas para enviar o pacote."
        case .tooManyStickers: "O pacote tem figurinhas demais."
        case .invalidEmojiCount(let n): "A figurinha \(n) precisa ter de 1 a 3 emojis."
        case .textTooLong: "O nome do pacote ou do autor passa de 128 caracteres."
        case .unreadableSticker(let n): "Não foi possível ler a imagem da figurinha \(n)."
        case .stickerTooLarge(let n): "A figurinha \(n) ficou grande demais (mais de 100KB) mesmo com a menor qualidade."
        case .trayTooLarge: "O ícone do pacote passou de 50KB."
        }
    }
}

/// Converte um pacote para o formato do WhatsApp, sem tocar em UI nem em pasteboard.
struct StickerPackExporter {
    static let stickerSide: CGFloat = 512
    static let traySide: CGFloat = 96
    static let maxStickerBytes = 100 * 1024
    static let maxTrayBytes = 50 * 1024
    static let minStickers = 3
    static let maxStickers = 30
    static let maxEmojis = 3
    static let maxTextLength = 128
    static let qualities: [Float] = [90, 80, 70, 60, 50, 40, 30, 20]

    let encoder: WebPEncoding
    let files: StickerFileStore

    static func validate(_ pack: StickerPack) throws {
        let stickers = pack.sortedStickers
        if stickers.count < minStickers { throw ExportError.tooFewStickers(missing: minStickers - stickers.count) }
        if stickers.count > maxStickers { throw ExportError.tooManyStickers }
        for (index, sticker) in stickers.enumerated() where !(1...maxEmojis).contains(sticker.emoji.count) {
            throw ExportError.invalidEmojiCount(sticker: index + 1)
        }
        if pack.name.count > maxTextLength || pack.author.count > maxTextLength { throw ExportError.textTooLong }
    }

    func export(_ pack: StickerPack) throws -> WhatsAppPayload {
        try Self.validate(pack)
        let stickers = pack.sortedStickers

        let exported = try stickers.enumerated().map { index, sticker in
            guard let data = try? files.read(sticker.fileName), let image = UIImage(data: data) else {
                throw ExportError.unreadableSticker(sticker: index + 1)
            }
            let webp = try encodeUnderLimit(Self.resized(image, to: Self.stickerSide), sticker: index + 1)
            return WhatsAppPayload.Sticker(webp: webp, emojis: sticker.emoji.map(String.init))
        }

        guard let firstData = try? files.read(stickers[0].fileName), let first = UIImage(data: firstData),
              let tray = Self.resized(first, to: Self.traySide).pngData() else {
            throw ExportError.unreadableSticker(sticker: 1)
        }
        guard tray.count < Self.maxTrayBytes else { throw ExportError.trayTooLarge }

        return WhatsAppPayload(identifier: pack.id.uuidString, name: pack.name, publisher: pack.author,
                               trayPNG: tray, stickers: exported)
    }

    /// Começa em qualidade alta e reduz até ficar abaixo de 100KB.
    private func encodeUnderLimit(_ image: UIImage, sticker: Int) throws -> Data {
        for quality in Self.qualities {
            let data = try encoder.encode(image, quality: quality)
            if data.count < Self.maxStickerBytes { return data }
        }
        throw ExportError.stickerTooLarge(sticker: sticker)
    }

    /// Redimensiona para um quadrado de `side` pixels reais, preservando a transparência.
    static func resized(_ image: UIImage, to side: CGFloat) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        // Sem isso, em aparelhos com tela P3 o PNG sai com 16 bits por canal e estoura o limite do ícone.
        format.preferredRange = .standard
        return UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format).image { _ in
            image.draw(in: CGRect(x: 0, y: 0, width: side, height: side))
        }
    }
}
