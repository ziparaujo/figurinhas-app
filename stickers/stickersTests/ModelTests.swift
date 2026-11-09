import Testing
import Foundation
import SwiftData
@testable import stickers

@MainActor
struct ModelTests {

    private func makeContainer(url: URL? = nil) throws -> ModelContainer {
        let config = url.map { ModelConfiguration(url: $0) } ?? ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: StickerPack.self, Sticker.self, configurations: config)
    }

    private func makeTempDirectory() throws -> URL {
        let dir = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }

    @Test func deletingPackDeletesItsStickers() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let pack = StickerPack(name: "Teste")
        context.insert(pack)
        pack.stickers = [Sticker(fileName: "a.png", order: 0), Sticker(fileName: "b.png", order: 1)]
        try context.save()
        #expect(try context.fetchCount(FetchDescriptor<Sticker>()) == 2)

        context.delete(pack)
        try context.save()

        #expect(try context.fetchCount(FetchDescriptor<StickerPack>()) == 0)
        #expect(try context.fetchCount(FetchDescriptor<Sticker>()) == 0)
    }

    @Test func fileStoreWritesReadsAndDeletes() throws {
        let store = StickerFileStore(directory: try makeTempDirectory())
        let data = Data([1, 2, 3, 4])

        let name = try store.write(data)
        #expect(try store.read(name) == data)

        try store.delete(name)
        #expect(throws: (any Error).self) { try store.read(name) }
    }

    @Test func packsAndStickersSurviveContainerRecreation() throws {
        let storeURL = try makeTempDirectory().appending(path: "test.store")

        do {
            let container = try makeContainer(url: storeURL)
            let context = container.mainContext
            let pack = StickerPack(name: "Persistido")
            context.insert(pack)
            pack.stickers = [Sticker(fileName: "a.png", order: 0, emoji: "😎")]
            try context.save()
        }

        let container = try makeContainer(url: storeURL)
        let context = container.mainContext
        let packs = try context.fetch(FetchDescriptor<StickerPack>())
        #expect(packs.count == 1)
        #expect(packs.first?.name == "Persistido")
        #expect(packs.first?.author == "Rod")
        #expect(packs.first?.stickers.first?.fileName == "a.png")
        #expect(packs.first?.stickers.first?.emoji == "😎")
    }
}
