import Foundation

struct DeletionManifest: Codable, Identifiable {
    struct Entry: Codable, Identifiable {
        let id: UUID
        let originalPath: String
        let trashedPath: String
        let size: Int64
        let confidence: FileConfidence
    }

    let id: UUID
    let createdAt: Date
    let appName: String
    let bundleIdentifier: String?
    let entries: [Entry]

    var totalSize: Int64 {
        entries.reduce(0) { $0 + $1.size }
    }
}

struct RestoreResult {
    struct FailedEntry: Identifiable {
        let entry: DeletionManifest.Entry
        let message: String

        var id: UUID { entry.id }
    }

    let restoredEntries: [DeletionManifest.Entry]
    let skippedMissingEntries: [DeletionManifest.Entry]
    let skippedConflictEntries: [DeletionManifest.Entry]
    let failedEntries: [FailedEntry]

    var restoredAllEntries: Bool {
        !restoredEntries.isEmpty
        && skippedMissingEntries.isEmpty
        && skippedConflictEntries.isEmpty
        && failedEntries.isEmpty
    }

    var hasIssues: Bool {
        !skippedMissingEntries.isEmpty || !skippedConflictEntries.isEmpty || !failedEntries.isEmpty
    }
}
