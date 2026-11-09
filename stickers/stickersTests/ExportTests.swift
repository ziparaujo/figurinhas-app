import Testing
import UIKit
import SwiftData
@testable import stickers

@MainActor
struct ExportTests {

    /// Devolve um tamanho que cai com a qualidade: q90 = 135KB, q60 = 90KB.
    private struct FakeEncoder: WebPEncoding {
        var bytesPerQuality = 1500
        func encode(_ image: UIImage, quality: Float) throws -> Data {
            Data(count: Int(quality) * bytesPerQuality)
        }
    }

    private struct Fixture {
        let container: ModelContainer
        let files: StickerFileStore
        let pack: StickerPack
    }

    private func makePNG(side: CGFloat = 512, noise: Bool = false) throws -> Data {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = false
        let image = UIGraphicsImageRenderer(size: CGSize(width: side, height: side), format: format).image { ctx in
            if noise {
                for y in stride(from: 0, to: Int(side), by: 2) {
                    for x in stride(from: 0, to: Int(side), by: 2) {
                        UIColor(red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1).setFill()
                        ctx.fill(CGRect(x: x, y: y, width: 2, height: 2))
                    }
                }
            } else {
                UIColor.orange.setFill()
                ctx.cgContext.fillEllipse(in: CGRect(x: 56, y: 56, width: side - 112, height: side - 112))
            }
        }
        return try #require(image.pngData())
    }

    private func makeFixture(stickers count: Int, noise: Bool = false, emoji: String = "😀") throws -> Fixture {
        let container = try ModelContainer(for: StickerPack.self, Sticker.self,
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let dir = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        let files = StickerFileStore(directory: dir)
        let pack = StickerPack(name: "Gatos")
        container.mainContext.insert(pack)
        let png = try makePNG(noise: noise)
        for i in 0..<count {
            pack.stickers.append(Sticker(fileName: try files.write(png), order: i, emoji: emoji))
        }
        return Fixture(container: container, files: files, pack: pack)
    }

    // MARK: 5.1 formatos

    @Test func exportsWebPStickersAndPNGTray() throws {
        let f = try makeFixture(stickers: 3)
        let payload = try StickerPackExporter(encoder: LibWebPEncoder(), files: f.files).export(f.pack)

        #expect(payload.stickers.count == 3)
        for sticker in payload.stickers {
            #expect(sticker.webp.prefix(4) == Data("RIFF".utf8))
            #expect(sticker.webp.dropFirst(8).prefix(4) == Data("WEBP".utf8))
            let decoded = try #require(UIImage(data: sticker.webp)?.cgImage)
            #expect(decoded.width == 512 && decoded.height == 512)
            #expect(sticker.webp.count < 100 * 1024)
        }
        #expect(payload.trayPNG.prefix(4) == Data([0x89, 0x50, 0x4E, 0x47]))
        let tray = try #require(UIImage(data: payload.trayPNG)?.cgImage)
        #expect(tray.width == 96 && tray.height == 96)
        #expect(payload.trayPNG.count < 50 * 1024)
        #expect(payload.publisher == "Rod")
    }

    @Test func payloadJSONHasWhatsAppFields() throws {
        let f = try makeFixture(stickers: 3)
        let payload = try StickerPackExporter(encoder: LibWebPEncoder(), files: f.files).export(f.pack)
        let json = try #require(JSONSerialization.jsonObject(with: try payload.jsonData()) as? [String: Any])
        #expect(json["name"] as? String == "Gatos")
        #expect(json["publisher"] as? String == "Rod")
        #expect(json["identifier"] as? String == f.pack.id.uuidString)
        #expect(json["tray_image"] is String)
        let stickers = try #require(json["stickers"] as? [[String: Any]])
        #expect(stickers.count == 3)
        #expect(stickers[0]["emojis"] as? [String] == ["😀"])
    }

    // MARK: 5.2 compressão

    @Test func qualityDropsUntilUnderLimit() throws {
        let f = try makeFixture(stickers: 3)
        let payload = try StickerPackExporter(encoder: FakeEncoder(), files: f.files).export(f.pack)
        #expect(payload.stickers.allSatisfy { $0.webp.count == 60 * 1500 })
    }

    @Test func errorIdentifiesStickerThatCannotFit() throws {
        let f = try makeFixture(stickers: 3)
        let exporter = StickerPackExporter(encoder: FakeEncoder(bytesPerQuality: 100_000), files: f.files)
        #expect(throws: ExportError.stickerTooLarge(sticker: 1)) { try exporter.export(f.pack) }
    }

    @Test func highEntropyImageEndsUnderLimitOrFailsIdentifyingSticker() throws {
        let f = try makeFixture(stickers: 3, noise: true)
        do {
            let payload = try StickerPackExporter(encoder: LibWebPEncoder(), files: f.files).export(f.pack)
            #expect(payload.stickers.allSatisfy { $0.webp.count < 100 * 1024 })
        } catch let error as ExportError {
            #expect(error == .stickerTooLarge(sticker: 1))
        }
    }

    // MARK: 5.3 validação

    @Test(arguments: [(2, false), (3, true), (30, true), (31, false)])
    func stickerCountBoundaries(count: Int, valid: Bool) throws {
        let f = try makeFixture(stickers: count)
        if valid {
            try StickerPackExporter.validate(f.pack)
        } else {
            #expect(throws: ExportError.self) { try StickerPackExporter.validate(f.pack) }
        }
    }

    @Test func missingCountIsReported() throws {
        let f = try makeFixture(stickers: 1)
        #expect(throws: ExportError.tooFewStickers(missing: 2)) { try StickerPackExporter.validate(f.pack) }
    }

    @Test(arguments: [("", false), ("😀", true), ("😀😎🙂", true), ("😀😎🙂🤔", false)])
    func emojiCountBoundaries(emoji: String, valid: Bool) throws {
        let f = try makeFixture(stickers: 3, emoji: emoji)
        if valid {
            try StickerPackExporter.validate(f.pack)
        } else {
            #expect(throws: ExportError.invalidEmojiCount(sticker: 1)) { try StickerPackExporter.validate(f.pack) }
        }
    }

    // MARK: 5.4 envio

    private final class Spy {
        var pasteboard: Data?
        var opened: URL?
    }

    private func sender(_ spy: Spy, installed: Bool) -> WhatsAppSender {
        WhatsAppSender(canOpen: { installed }, writePasteboard: { spy.pasteboard = $0 }, open: { spy.opened = $0 })
    }

    @Test func sendWritesPasteboardAndOpensWhatsApp() throws {
        let f = try makeFixture(stickers: 3)
        let spy = Spy()
        try sender(spy, installed: true).send(f.pack, using: StickerPackExporter(encoder: FakeEncoder(), files: f.files))
        #expect(spy.pasteboard != nil)
        #expect(spy.opened == URL(string: "whatsapp://stickerPack"))
    }

    @Test func missingWhatsAppDoesNothingAndExplains() throws {
        let f = try makeFixture(stickers: 3)
        let spy = Spy()
        #expect(throws: WhatsAppSendError.self) {
            try sender(spy, installed: false).send(f.pack, using: StickerPackExporter(encoder: FakeEncoder(), files: f.files))
        }
        #expect(spy.pasteboard == nil && spy.opened == nil)
        #expect(WhatsAppSendError.notInstalled.localizedDescription.contains("WhatsApp"))
        #expect(f.pack.stickers.count == 3)
    }

    @Test func exportFailureDoesNotOpenWhatsApp() throws {
        let f = try makeFixture(stickers: 3)
        let spy = Spy()
        let exporter = StickerPackExporter(encoder: FakeEncoder(bytesPerQuality: 100_000), files: f.files)
        #expect(throws: ExportError.self) { try sender(spy, installed: true).send(f.pack, using: exporter) }
        #expect(spy.pasteboard == nil && spy.opened == nil)
        #expect(ExportError.stickerTooLarge(sticker: 1).localizedDescription.contains("figurinha 1"))
    }
}
