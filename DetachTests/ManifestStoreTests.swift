import XCTest
@testable import Detach

final class ManifestStoreTests: XCTestCase {
    private var temporaryDirectory: URL!

    override func setUpWithError() throws {
        temporaryDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent("DetachManifestStoreTests-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        if let temporaryDirectory {
            try? FileManager.default.removeItem(at: temporaryDirectory)
        }
    }

    func testLoadAllReturnsSavedManifestsNewestFirst() throws {
        let store = ManifestStore(applicationSupportDirectory: temporaryDirectory)
        let older = makeManifest(appName: "Older", createdAt: Date(timeIntervalSince1970: 100))
        let newer = makeManifest(appName: "Newer", createdAt: Date(timeIntervalSince1970: 200))

        try store.save(older)
        try store.save(newer)

        let loaded = try store.loadAll()

        XCTAssertEqual(loaded.map(\.id), [newer.id, older.id])
    }

    func testLoadAllIgnoresMalformedFiles() throws {
        let store = ManifestStore(applicationSupportDirectory: temporaryDirectory)
        let manifest = makeManifest(appName: "Example", createdAt: Date(timeIntervalSince1970: 100))
        try store.save(manifest)

        let badURL = temporaryDirectory
            .appendingPathComponent("Detach", isDirectory: true)
            .appendingPathComponent("DeletionManifests", isDirectory: true)
            .appendingPathComponent("broken.json")
        try Data("not-json".utf8).write(to: badURL)

        let loaded = try store.loadAll()

        XCTAssertEqual(loaded.map(\.id), [manifest.id])
    }

    func testDeleteRemovesSelectedManifestFile() throws {
        let store = ManifestStore(applicationSupportDirectory: temporaryDirectory)
        let first = makeManifest(appName: "First", createdAt: Date(timeIntervalSince1970: 100))
        let second = makeManifest(appName: "Second", createdAt: Date(timeIntervalSince1970: 200))
        try store.save(first)
        try store.save(second)

        try store.delete(second)

        let loaded = try store.loadAll()
        XCTAssertEqual(loaded.map(\.id), [first.id])
    }
}

private func makeManifest(appName: String, createdAt: Date) -> DeletionManifest {
    DeletionManifest(
        id: UUID(),
        createdAt: createdAt,
        appName: appName,
        bundleIdentifier: "com.example.\(appName.lowercased())",
        entries: [
            DeletionManifest.Entry(
                id: UUID(),
                originalPath: "/Applications/\(appName).app",
                trashedPath: "/Users/test/.Trash/\(appName).app",
                size: 42,
                confidence: .high
            )
        ]
    )
}
