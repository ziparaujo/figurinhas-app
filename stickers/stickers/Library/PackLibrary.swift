import Foundation
import SwiftData

enum PackLibraryError: Error {
    case packFull
}

/// Regras de pacotes e figurinhas, sem UI, para serem testáveis.
struct PackLibrary {
    static let maxStickersPerPack = 30

    let context: ModelContext
    let files: StickerFileStore

    /// Nome sem espaços nas pontas, ou nil se vazio.
    static func validName(_ name: String) -> String? {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    @discardableResult
    func createPack(named name: String) -> StickerPack? {
        guard let name = Self.validName(name) else { return nil }
        let pack = StickerPack(name: name)
        context.insert(pack)
        return pack
    }

    @discardableResult
    func rename(_ pack: StickerPack, to name: String) -> Bool {
        guard let name = Self.validName(name) else { return false }
        pack.name = name
        return true
    }

    func delete(_ pack: StickerPack) {
        for sticker in pack.stickers { try? files.delete(sticker.fileName) }
        context.delete(pack)
    }

    static func canAddSticker(to pack: StickerPack) -> Bool {
        pack.stickers.count < maxStickersPerPack
    }

    func remove(_ sticker: Sticker) {
        try? files.delete(sticker.fileName)
        context.delete(sticker)
    }

    /// Guarda o PNG final da figurinha e a adiciona ao fim do pacote.
    @discardableResult
    func addSticker(png: Data, to pack: StickerPack, emoji: String = Sticker.defaultEmoji) throws -> Sticker {
        guard Self.canAddSticker(to: pack) else { throw PackLibraryError.packFull }
        let fileName = try files.write(png)
        let order = (pack.stickers.map(\.order).max() ?? -1) + 1
        let sticker = Sticker(fileName: fileName, order: order, emoji: emoji)
        pack.stickers.append(sticker)
        return sticker
    }
}
