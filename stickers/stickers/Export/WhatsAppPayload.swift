import Foundation

/// Pacote já convertido para o formato do WhatsApp, pronto para o pasteboard.
struct WhatsAppPayload {
    struct Sticker {
        let webp: Data
        let emojis: [String]
    }

    let identifier: String
    let name: String
    let publisher: String
    let trayPNG: Data
    let stickers: [Sticker]

    func jsonData() throws -> Data {
        let json: [String: Any] = [
            "identifier": identifier,
            "name": name,
            "publisher": publisher,
            "tray_image": trayPNG.base64EncodedString(),
            "stickers": stickers.map { ["image_data": $0.webp.base64EncodedString(), "emojis": $0.emojis] },
        ]
        return try JSONSerialization.data(withJSONObject: json)
    }
}
