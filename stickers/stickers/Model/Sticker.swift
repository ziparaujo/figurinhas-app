import Foundation
import SwiftData

@Model
final class Sticker {
    static let defaultEmoji = "😀"

    @Attribute(.unique) var id: UUID
    var emoji: String
    var order: Int
    /// Nome do PNG final de 512x512 dentro do `StickerFileStore`.
    var fileName: String
    var pack: StickerPack?

    init(fileName: String, order: Int, emoji: String = Sticker.defaultEmoji) {
        self.id = UUID()
        self.fileName = fileName
        self.order = order
        self.emoji = emoji
    }
}
