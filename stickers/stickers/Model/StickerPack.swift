import Foundation
import SwiftData

@Model
final class StickerPack {
    static let defaultAuthor = "Rod"

    @Attribute(.unique) var id: UUID
    var name: String
    var author: String
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Sticker.pack)
    var stickers: [Sticker] = []

    init(name: String, author: String = StickerPack.defaultAuthor) {
        self.id = UUID()
        self.name = name
        self.author = author
        self.createdAt = Date()
    }

    var sortedStickers: [Sticker] {
        stickers.sorted { $0.order < $1.order }
    }
}
