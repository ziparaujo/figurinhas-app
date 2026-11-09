import Foundation

/// Guarda em arquivo o PNG final de cada figurinha; o banco só guarda o nome.
struct StickerFileStore {
    let directory: URL

    static var `default`: StickerFileStore {
        let base = URL.applicationSupportDirectory.appending(path: "Stickers", directoryHint: .isDirectory)
        return StickerFileStore(directory: base)
    }

    /// Grava o PNG e devolve o nome do arquivo.
    func write(_ data: Data) throws -> String {
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        let fileName = "\(UUID().uuidString).png"
        try data.write(to: url(for: fileName), options: .atomic)
        return fileName
    }

    func read(_ fileName: String) throws -> Data {
        try Data(contentsOf: url(for: fileName))
    }

    func delete(_ fileName: String) throws {
        try FileManager.default.removeItem(at: url(for: fileName))
    }

    private func url(for fileName: String) -> URL {
        directory.appending(path: fileName)
    }
}
