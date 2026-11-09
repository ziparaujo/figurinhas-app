import SwiftUI

/// Ícone do pacote: a primeira figurinha, ou um ícone genérico se estiver vazio.
struct PackIconView: View {
    let pack: StickerPack
    var size: CGFloat = 48

    var body: some View {
        Group {
            if let first = pack.sortedStickers.first,
               let data = try? StickerFileStore.default.read(first.fileName),
               let image = UIImage(data: data) {
                Image(uiImage: image).resizable().scaledToFit()
            } else {
                Image(systemName: "face.smiling")
                    .resizable().scaledToFit().padding(size * 0.2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
    }
}
