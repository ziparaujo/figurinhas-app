import Testing
import Foundation
import SwiftData
@testable import stickers

@MainActor
struct PackLibraryTests {

    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(for: StickerPack.self, Sticker.self,
                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
    }

    private func makeLibrary(_ container: ModelContainer) -> PackLibrary {
        let dir = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        return PackLibrary(context: container.mainContext, files: StickerFileStore(directory: dir))
    }

    @Test func validNameTrimsAndRejectsBlank() {
        #expect(PackLibrary.validName("  Gatos ") == "Gatos")
        #expect(PackLibrary.validName("") == nil)
        #expect(PackLibrary.validName("   \n ") == nil)
    }

    @Test func createRejectsBlankName() throws {
        let container = try makeContainer()
        let library = makeLibrary(container)
        #expect(library.createPack(named: "  ") == nil)
        #expect(try container.mainContext.fetchCount(FetchDescriptor<StickerPack>()) == 0)
        #expect(library.createPack(named: "Gatos")?.name == "Gatos")
        #expect(try container.mainContext.fetchCount(FetchDescriptor<StickerPack>()) == 1)
    }

    @Test func renameRejectsBlankAndKeepsOldName() throws {
        let container = try makeContainer()
        let library = makeLibrary(container)
        let pack = try #require(library.createPack(named: "Gatos"))
        #expect(library.rename(pack, to: " ") == false)
        #expect(pack.name == "Gatos")
        #expect(library.rename(pack, to: "Cães") == true)
        #expect(pack.name == "Cães")
    }

    @Test func deleteRemovesPackStickersAndFiles() throws {
        let container = try makeContainer()
        let library = makeLibrary(container)
        let pack = try #require(library.createPack(named: "Gatos"))
        let name = try library.files.write(Data([1]))
        pack.stickers.append(Sticker(fileName: name, order: 0))

        library.delete(pack)

        #expect(try container.mainContext.fetchCount(FetchDescriptor<StickerPack>()) == 0)
        #expect(try container.mainContext.fetchCount(FetchDescriptor<Sticker>()) == 0)
        #expect(throws: (any Error).self) { try library.files.read(name) }
    }

    @Test func limitBlocksAtThirtyStickers() throws {
        let container = try makeContainer()
        let library = makeLibrary(container)
        let pack = try #require(library.createPack(named: "Gatos"))
        for i in 0..<29 { pack.stickers.append(Sticker(fileName: "\(i).png", order: i)) }
        #expect(PackLibrary.canAddSticker(to: pack))
        pack.stickers.append(Sticker(fileName: "29.png", order: 29))
        #expect(PackLibrary.canAddSticker(to: pack) == false)
    }

    @Test func removeStickerDeletesItAndItsFile() throws {
        let container = try makeContainer()
        let library = makeLibrary(container)
        let pack = try #require(library.createPack(named: "Gatos"))
        let name = try library.files.write(Data([1]))
        let sticker = Sticker(fileName: name, order: 0)
        pack.stickers.append(sticker)

        library.remove(sticker)

        #expect(try container.mainContext.fetchCount(FetchDescriptor<Sticker>()) == 0)
        #expect(throws: (any Error).self) { try library.files.read(name) }
    }
}
