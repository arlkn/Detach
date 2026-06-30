import XCTest
@testable import Detach

final class FileDeletionServiceTests: XCTestCase {
    func testMoveAppToTrashMovesOnlyAppByDefault() throws {
        let trash = MockTrashService()
        let store = MockManifestStore()
        let service = FileDeletionService(trashService: trash, manifestStore: store)
        let app = makeApp()

        let manifest = try service.moveAppToTrash(app)

        XCTAssertEqual(trash.movedItems, [app.url])
        XCTAssertEqual(manifest.entries.count, 1)
        XCTAssertEqual(manifest.entries.first?.originalPath, "/Applications/Example.app")
        XCTAssertEqual(store.savedManifest?.id, manifest.id)
    }

    func testMoveAppToTrashCanIncludeRelatedFiles() throws {
        let trash = MockTrashService()
        let service = FileDeletionService(trashService: trash, manifestStore: MockManifestStore())
        let app = makeApp()
        let file = makeRelatedFile()

        let manifest = try service.moveAppToTrash(app, including: [file])

        XCTAssertEqual(trash.movedItems, [app.url, file.url])
        XCTAssertEqual(manifest.entries.count, 2)
    }

    func testProtectedAppIsNotMoved() {
        let trash = MockTrashService()
        let service = FileDeletionService(trashService: trash, manifestStore: MockManifestStore())
        let app = InstalledApp(
            id: URL(fileURLWithPath: "/System/Applications/Safari.app"),
            url: URL(fileURLWithPath: "/System/Applications/Safari.app"),
            name: "Safari",
            bundleIdentifier: "com.apple.Safari",
            version: nil,
            icon: nil,
            size: 0,
            isAppleSignedOrProtected: true,
            isRunning: false
        )

        XCTAssertThrowsError(try service.moveAppToTrash(app))
        XCTAssertTrue(trash.movedItems.isEmpty)
    }

    func testMoveToTrashUsesTrashServiceAndReturnsManifest() throws {
        let trash = MockTrashService()
        let store = MockManifestStore()
        let service = FileDeletionService(trashService: trash, manifestStore: store)
        let app = makeApp()
        let file = makeRelatedFile()

        let manifest = try service.moveToTrash(files: [file], for: app)

        XCTAssertEqual(trash.movedItems, [file.url])
        XCTAssertEqual(manifest.entries.count, 1)
        XCTAssertEqual(manifest.entries.first?.trashedPath, "/Users/test/.Trash/com.example.app")
        XCTAssertEqual(store.savedManifest?.id, manifest.id)
    }

    func testAdminRequiredFileIsNotMoved() {
        let trash = MockTrashService()
        let service = FileDeletionService(trashService: trash, manifestStore: MockManifestStore())
        let app = InstalledApp(
            id: URL(fileURLWithPath: "/Applications/Example.app"),
            url: URL(fileURLWithPath: "/Applications/Example.app"),
            name: "Example",
            bundleIdentifier: "com.example.app",
            version: nil,
            icon: nil,
            size: 0,
            isAppleSignedOrProtected: false,
            isRunning: false
        )
        let file = RelatedFile(
            id: URL(fileURLWithPath: "/Library/Preferences/com.example.app.plist"),
            url: URL(fileURLWithPath: "/Library/Preferences/com.example.app.plist"),
            size: 42,
            kind: .preferences,
            confidence: .medium,
            reason: "System-wide match",
            requiresAdmin: true,
            isSymbolicLink: false
        )

        XCTAssertThrowsError(try service.moveToTrash(files: [file], for: app))
        XCTAssertTrue(trash.movedItems.isEmpty)
    }

    func testAdminFilesUseAdminTrashServiceAndAreRecordedInManifest() throws {
        let trash = MockTrashService()
        let adminTrash = MockAdminTrashService()
        let store = MockManifestStore()
        let service = FileDeletionService(
            trashService: trash,
            adminTrashService: adminTrash,
            manifestStore: store
        )
        let app = makeApp()
        let userFile = makeRelatedFile()
        let adminFile = makeAdminRelatedFile()

        let manifest = try service.moveAppToTrash(
            app,
            including: [userFile],
            includingAdminFiles: [adminFile]
        )

        XCTAssertEqual(trash.movedItems, [app.url, userFile.url])
        XCTAssertEqual(adminTrash.movedItems, [adminFile.url])
        XCTAssertEqual(manifest.entries.count, 3)
        XCTAssertEqual(manifest.entries.last?.originalPath, adminFile.url.path)
        XCTAssertEqual(manifest.entries.last?.trashedPath, "/Users/test/.Trash/com.example.app.admin")
    }

    func testProtectedAdminPathIsRejectedBeforeElevatedMove() {
        let trash = MockTrashService()
        let adminTrash = MockAdminTrashService()
        let service = FileDeletionService(
            trashService: trash,
            adminTrashService: adminTrash,
            manifestStore: MockManifestStore()
        )
        let app = makeApp()
        let protectedFile = RelatedFile(
            id: URL(fileURLWithPath: "/System/Library/Caches/com.example.app"),
            url: URL(fileURLWithPath: "/System/Library/Caches/com.example.app"),
            size: 42,
            kind: .caches,
            confidence: .medium,
            reason: "Protected system path",
            requiresAdmin: true,
            isSymbolicLink: false
        )

        XCTAssertThrowsError(try service.moveAppToTrash(app, includingAdminFiles: [protectedFile]))
        XCTAssertTrue(adminTrash.movedItems.isEmpty)
    }
}

private func makeApp() -> InstalledApp {
    InstalledApp(
        id: URL(fileURLWithPath: "/Applications/Example.app"),
        url: URL(fileURLWithPath: "/Applications/Example.app"),
        name: "Example",
        bundleIdentifier: "com.example.app",
        version: "1.0",
        icon: nil,
        size: 10,
        isAppleSignedOrProtected: false,
        isRunning: false
    )
}

private func makeRelatedFile() -> RelatedFile {
    RelatedFile(
        id: URL(fileURLWithPath: "/Users/test/Library/Caches/com.example.app"),
        url: URL(fileURLWithPath: "/Users/test/Library/Caches/com.example.app"),
        size: 128,
        kind: .caches,
        confidence: .high,
        reason: "Bundle identifier match",
        requiresAdmin: false,
        isSymbolicLink: false
    )
}

private func makeAdminRelatedFile() -> RelatedFile {
    RelatedFile(
        id: URL(fileURLWithPath: "/Library/Caches/com.example.app.admin"),
        url: URL(fileURLWithPath: "/Library/Caches/com.example.app.admin"),
        size: 256,
        kind: .caches,
        confidence: .medium,
        reason: "Bundle identifier match in system-wide location",
        requiresAdmin: true,
        isSymbolicLink: false
    )
}

private final class MockTrashService: TrashServicing {
    var movedItems: [URL] = []

    func moveItemToTrash(_ url: URL) throws -> URL {
        movedItems.append(url)
        return URL(fileURLWithPath: "/Users/test/.Trash").appendingPathComponent(url.lastPathComponent)
    }
}

private final class MockAdminTrashService: AdminTrashServicing {
    var movedItems: [URL] = []

    func moveAdminItemToTrash(_ url: URL, currentUserHome: URL) throws -> URL {
        movedItems.append(url)
        return URL(fileURLWithPath: "/Users/test/.Trash").appendingPathComponent(url.lastPathComponent)
    }
}

private final class MockManifestStore: ManifestStoring {
    var savedManifest: DeletionManifest?

    func save(_ manifest: DeletionManifest) throws {
        savedManifest = manifest
    }

    func loadAll() throws -> [DeletionManifest] {
        savedManifest.map { [$0] } ?? []
    }

    func delete(_ manifest: DeletionManifest) throws {
        if savedManifest?.id == manifest.id {
            savedManifest = nil
        }
    }
}
