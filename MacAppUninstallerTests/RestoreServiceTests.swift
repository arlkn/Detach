import XCTest
@testable import MacAppUninstaller

final class RestoreServiceTests: XCTestCase {
    private var temporaryDirectory: URL!

    override func setUpWithError() throws {
        temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("DetachRestoreServiceTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let temporaryDirectory {
            try? FileManager.default.removeItem(at: temporaryDirectory)
        }
    }

    func testRestoreMovesTrashedItemToOriginalPath() throws {
        let service = RestoreService()
        let trashed = temporaryDirectory.appendingPathComponent("Trash/Example.app")
        let original = temporaryDirectory.appendingPathComponent("Applications/Example.app")
        try FileManager.default.createDirectory(at: trashed.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("app".utf8).write(to: trashed)

        let result = try service.restore(makeRestoreManifest(original: original, trashed: trashed))

        XCTAssertEqual(result.restoredEntries.count, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: original.path))
        XCTAssertFalse(FileManager.default.fileExists(atPath: trashed.path))
    }

    func testRestoreCreatesMissingParentDirectories() throws {
        let service = RestoreService()
        let trashed = temporaryDirectory.appendingPathComponent("Trash/com.example.app.plist")
        let original = temporaryDirectory.appendingPathComponent("Library/Preferences/com.example.app.plist")
        try FileManager.default.createDirectory(at: trashed.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("prefs".utf8).write(to: trashed)

        let result = try service.restore(makeRestoreManifest(original: original, trashed: trashed))

        XCTAssertEqual(result.restoredEntries.count, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: original.path))
    }

    func testRestoreSkipsWhenDestinationAlreadyExists() throws {
        let service = RestoreService()
        let trashed = temporaryDirectory.appendingPathComponent("Trash/Example.app")
        let original = temporaryDirectory.appendingPathComponent("Applications/Example.app")
        try FileManager.default.createDirectory(at: trashed.deletingLastPathComponent(), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: original.deletingLastPathComponent(), withIntermediateDirectories: true)
        try Data("trashed".utf8).write(to: trashed)
        try Data("existing".utf8).write(to: original)

        let result = try service.restore(makeRestoreManifest(original: original, trashed: trashed))

        XCTAssertTrue(result.restoredEntries.isEmpty)
        XCTAssertEqual(result.skippedConflictEntries.count, 1)
        XCTAssertTrue(FileManager.default.fileExists(atPath: trashed.path))
    }

    func testRestoreSkipsWhenTrashedItemIsMissing() throws {
        let service = RestoreService()
        let trashed = temporaryDirectory.appendingPathComponent("Trash/Missing.app")
        let original = temporaryDirectory.appendingPathComponent("Applications/Missing.app")

        let result = try service.restore(makeRestoreManifest(original: original, trashed: trashed))

        XCTAssertTrue(result.restoredEntries.isEmpty)
        XCTAssertEqual(result.skippedMissingEntries.count, 1)
    }
}

private func makeRestoreManifest(original: URL, trashed: URL) -> DeletionManifest {
    DeletionManifest(
        id: UUID(),
        createdAt: Date(),
        appName: "Example",
        bundleIdentifier: "com.example.app",
        entries: [
            DeletionManifest.Entry(
                id: UUID(),
                originalPath: original.path,
                trashedPath: trashed.path,
                size: 12,
                confidence: .high
            )
        ]
    )
}
