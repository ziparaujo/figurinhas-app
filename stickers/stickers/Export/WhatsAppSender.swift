import UIKit

enum WhatsAppSendError: LocalizedError {
    case notInstalled

    var errorDescription: String? {
        "O WhatsApp é necessário para adicionar o pacote. Instale-o e tente de novo."
    }
}

/// Entrega o pacote ao WhatsApp pelo pasteboard e pelo esquema `whatsapp://stickerPack`.
struct WhatsAppSender {
    static let pasteboardType = "net.whatsapp.third-party.sticker-pack"
    static let pasteboardExpiration: TimeInterval = 60
    static let url = URL(string: "whatsapp://stickerPack")!

    var canOpen: () -> Bool
    var writePasteboard: (Data) -> Void
    var open: (URL) -> Void

    @MainActor
    static var live: WhatsAppSender {
        WhatsAppSender(
            canOpen: { UIApplication.shared.canOpenURL(URL(string: "whatsapp://")!) },
            writePasteboard: { data in
                UIPasteboard.general.setItems(
                    [[pasteboardType: data]],
                    options: [.localOnly: true, .expirationDate: Date(timeIntervalSinceNow: pasteboardExpiration)]
                )
            },
            open: { UIApplication.shared.open($0) }
        )
    }

    /// Exporta e envia. Se o WhatsApp não existe ou a exportação falha, nada é gravado nem aberto.
    func send(_ pack: StickerPack, using exporter: StickerPackExporter) throws {
        guard canOpen() else { throw WhatsAppSendError.notInstalled }
        let json = try exporter.export(pack).jsonData()
        writePasteboard(json)
        open(Self.url)
    }
}
