import Testing
import UIKit
import SwiftData
@testable import stickers

@MainActor
struct EditorTests {

    private struct Pixels {
        let width: Int, height: Int
        let data: [UInt8]  // RGBA, premultiplicado

        init(_ image: UIImage) throws {
            let cg = try #require(image.cgImage)
            width = cg.width
            height = cg.height
            var buffer = [UInt8](repeating: 0, count: width * height * 4)
            let ctx = try #require(CGContext(data: &buffer, width: width, height: height, bitsPerComponent: 8,
                                             bytesPerRow: width * 4, space: CGColorSpaceCreateDeviceRGB(),
                                             bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
            ctx.draw(cg, in: CGRect(x: 0, y: 0, width: width, height: height))
            data = buffer
        }

        func rgba(_ x: Int, _ y: Int) -> (r: Int, g: Int, b: Int, a: Int) {
            let i = (y * width + x) * 4
            return (Int(data[i]), Int(data[i + 1]), Int(data[i + 2]), Int(data[i + 3]))
        }
    }

    private func textCanvas() -> StickerCanvasView {
        StickerCanvasView(text: "A", textPosition: CGPoint(x: 256, y: 256))
    }

    private func solidPhoto() -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: CGSize(width: 200, height: 100), format: format).image {
            UIColor.red.setFill()
            $0.fill(CGRect(x: 0, y: 0, width: 200, height: 100))
        }
    }

    @Test func rendersAt512x512() throws {
        let image = try #require(StickerRenderer.render(textCanvas()))
        let pixels = try Pixels(image)
        #expect(pixels.width == 512)
        #expect(pixels.height == 512)
    }

    @Test func uncoveredAreasAreTransparent() throws {
        let canvas = StickerCanvasView(photo: solidPhoto())
        let pixels = try Pixels(try #require(StickerRenderer.render(canvas)))
        // foto 2:1 caber no canvas quadrado: faixa de cima fica descoberta
        #expect(pixels.rgba(256, 10).a == 0)
        #expect(pixels.rgba(256, 256).a == 255)
    }

    @Test func textHasBlackOutlineAroundWhiteFill() throws {
        let pixels = try Pixels(try #require(StickerRenderer.render(textCanvas())))
        var whiteCount = 0, blackCount = 0
        var minX = Int.max, whiteRow = 0
        for y in 0..<pixels.height {
            for x in 0..<pixels.width {
                let p = pixels.rgba(x, y)
                if p.a == 255 && p.r > 240 && p.g > 240 && p.b > 240 {
                    whiteCount += 1
                    if x < minX { minX = x; whiteRow = y }
                } else if p.a == 255 && p.r < 30 && p.g < 30 && p.b < 30 {
                    blackCount += 1
                }
            }
        }
        #expect(whiteCount > 100)
        #expect(blackCount > 100)
        let beside = pixels.rgba(minX - 2, whiteRow)
        #expect(beside.a > 200 && beside.r < 80)
    }

    @Test func matchesReferencePNG() throws {
        let image = try #require(StickerRenderer.render(textCanvas()))
        let png = try #require(image.pngData())
        let reference = URL(filePath: #filePath).deletingLastPathComponent().appending(path: "sticker-reference.png")

        guard let expectedData = try? Data(contentsOf: reference) else {
            try png.write(to: reference)
            Issue.record("Referência criada em \(reference.path); rode de novo.")
            return
        }
        let actual = try Pixels(image)
        let expected = try Pixels(try #require(UIImage(data: expectedData)))
        #expect(actual.width == expected.width && actual.height == expected.height)

        var differing = 0
        for i in stride(from: 0, to: actual.data.count, by: 4) {
            let diff = (0..<4).map { abs(Int(actual.data[i + $0]) - Int(expected.data[i + $0])) }.max() ?? 0
            if diff > 32 { differing += 1 }
        }
        #expect(Double(differing) / Double(actual.width * actual.height) < 0.005)
    }

    @Test func textPositionIsClampedToCanvas() {
        let state = StickerEditorState()
        state.setText(position: CGPoint(x: -50, y: 900))
        #expect(state.textPosition == CGPoint(x: 0, y: 512))
        state.setText(position: CGPoint(x: 100, y: 200))
        #expect(state.textPosition == CGPoint(x: 100, y: 200))
    }

    @Test func textPositionMovesTheRenderedText() throws {
        let left = try Pixels(try #require(StickerRenderer.render(
            StickerCanvasView(text: "A", textPosition: CGPoint(x: 120, y: 256)))))
        #expect(left.rgba(120, 256).a == 255 || left.rgba(130, 256).a == 255)
        #expect(left.rgba(400, 256).a == 0)
    }

    @Test func cannotSaveWithoutPhoto() {
        let state = StickerEditorState()
        #expect(state.canSave == false)
        state.photo = solidPhoto()
        #expect(state.canSave)
    }

    @Test func addStickerUsesDefaultEmojiAndRefusesPastLimit() throws {
        let container = try ModelContainer(for: StickerPack.self, Sticker.self,
                                           configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let dir = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString, directoryHint: .isDirectory)
        let library = PackLibrary(context: container.mainContext, files: StickerFileStore(directory: dir))
        let pack = try #require(library.createPack(named: "Gatos"))

        let first = try library.addSticker(png: Data([1]), to: pack)
        #expect(first.emoji == "😀")
        #expect(pack.sortedStickers.map(\.order) == [0])
        #expect(try library.files.read(first.fileName) == Data([1]))

        for _ in 1..<30 { try library.addSticker(png: Data([2]), to: pack) }
        #expect(pack.stickers.count == 30)
        #expect(throws: PackLibraryError.packFull) { try library.addSticker(png: Data([3]), to: pack) }
        #expect(pack.stickers.count == 30)
    }
}
