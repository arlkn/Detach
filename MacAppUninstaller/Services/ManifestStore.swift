import Foundation

protocol ManifestStoring {
    func save(_ manifest: DeletionManifest) throws
    func loadAll() throws -> [DeletionManifest]
    func delete(_ manifest: DeletionManifest) throws
}

final class ManifestStore: ManifestStoring {
    private let fileManager: FileManager
    private let applicationSupportDirectory: URL?

    init(fileManager: FileManager = .default, applicationSupportDirectory: URL? = nil) {
        self.fileManager = fileManager
        self.applicationSupportDirectory = applicationSupportDirectory
    }

    convenience init(applicationSupportDirectory: URL) {
        self.init(fileManager: .default, applicationSupportDirectory: applicationSupportDirectory)
    }

    func save(_ manifest: DeletionManifest) throws {
        let directory = try manifestsDirectory()
        let formatter = ISO8601DateFormatter()
        let safeDate = formatter.string(from: manifest.createdAt).replacingOccurrences(of: ":", with: "-")
        let filename = "\(safeDate)-\(manifest.id.uuidString).json"
        let url = directory.appendingPathComponent(filename)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(manifest).write(to: url, options: .atomic)
    }

    func loadAll() throws -> [DeletionManifest] {
        let directory = try manifestsDirectory()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let urls = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )

        return urls
            .filter { $0.pathExtension == "json" }
            .compactMap { url in
                guard let data = try? Data(contentsOf: url) else { return nil }
                return try? decoder.decode(DeletionManifest.self, from: data)
            }
            .sorted { $0.createdAt > $1.createdAt }
    }

    func delete(_ manifest: DeletionManifest) throws {
        let directory = try manifestsDirectory()
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let urls = try fileManager.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )

        for url in urls where url.pathExtension == "json" {
            if url.lastPathComponent.contains(manifest.id.uuidString) {
                try fileManager.removeItem(at: url)
                return
            }

            guard let data = try? Data(contentsOf: url),
                  let savedManifest = try? decoder.decode(DeletionManifest.self, from: data),
                  savedManifest.id == manifest.id else {
                continue
            }
            try fileManager.removeItem(at: url)
            return
        }
    }

    private func manifestsDirectory() throws -> URL {
        let base = try applicationSupportDirectory ?? fileManager.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let directory = base.appendingPathComponent("Detach/DeletionManifests", isDirectory: true)
        try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }
}
