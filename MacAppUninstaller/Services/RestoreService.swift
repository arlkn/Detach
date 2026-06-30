import Foundation

protocol RestoreServicing {
    func restore(_ manifest: DeletionManifest) throws -> RestoreResult
}

final class RestoreService: RestoreServicing {
    private let fileManager: FileManager

    init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    func restore(_ manifest: DeletionManifest) throws -> RestoreResult {
        var restoredEntries: [DeletionManifest.Entry] = []
        var skippedMissingEntries: [DeletionManifest.Entry] = []
        var skippedConflictEntries: [DeletionManifest.Entry] = []
        var failedEntries: [RestoreResult.FailedEntry] = []

        for entry in manifest.entries {
            let trashedURL = URL(fileURLWithPath: entry.trashedPath)
            let originalURL = URL(fileURLWithPath: entry.originalPath)

            guard fileManager.fileExists(atPath: trashedURL.path) else {
                skippedMissingEntries.append(entry)
                continue
            }

            guard !fileManager.fileExists(atPath: originalURL.path) else {
                skippedConflictEntries.append(entry)
                continue
            }

            do {
                try fileManager.createDirectory(
                    at: originalURL.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try fileManager.moveItem(at: trashedURL, to: originalURL)
                restoredEntries.append(entry)
            } catch {
                failedEntries.append(.init(entry: entry, message: error.localizedDescription))
            }
        }

        return RestoreResult(
            restoredEntries: restoredEntries,
            skippedMissingEntries: skippedMissingEntries,
            skippedConflictEntries: skippedConflictEntries,
            failedEntries: failedEntries
        )
    }
}
