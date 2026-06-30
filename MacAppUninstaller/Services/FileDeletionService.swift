import Foundation

enum FileDeletionError: LocalizedError {
    case protectedApp(URL)
    case runningApp(String)
    case protectedPath(URL)
    case requiresAdmin(URL)
    case notAdminEligible(URL)
    case symbolicLink(URL)

    var errorDescription: String? {
        switch self {
        case .protectedApp(let url):
            return "Protected Apple or system app cannot be moved: \(url.path)"
        case .runningApp(let name):
            return "\(name) is currently running. Quit it before uninstalling."
        case .protectedPath(let url):
            return "Protected path cannot be moved: \(url.path)"
        case .requiresAdmin(let url):
            return "Admin-only path is listed but not moved in v1: \(url.path)"
        case .notAdminEligible(let url):
            return "Admin-only path is not safe for elevated removal: \(url.path)"
        case .symbolicLink(let url):
            return "Symbolic links are not moved automatically: \(url.path)"
        }
    }
}

final class FileDeletionService {
    private let trashService: TrashServicing
    private let adminTrashService: AdminTrashServicing
    private let manifestStore: ManifestStoring
    private let currentUserHome: URL

    init(
        trashService: TrashServicing = WorkspaceTrashService(),
        adminTrashService: AdminTrashServicing = AdminTrashService(),
        manifestStore: ManifestStoring = ManifestStore(),
        currentUserHome: URL = FileManager.default.homeDirectoryForCurrentUser
    ) {
        self.trashService = trashService
        self.adminTrashService = adminTrashService
        self.manifestStore = manifestStore
        self.currentUserHome = currentUserHome
    }

    func moveAppToTrash(
        _ app: InstalledApp,
        including files: [RelatedFile] = [],
        includingAdminFiles adminFiles: [RelatedFile] = []
    ) throws -> DeletionManifest {
        try validate(app)

        var entries: [DeletionManifest.Entry] = []
        let trashedAppURL = try trashService.moveItemToTrash(app.url)
        entries.append(.init(
            id: UUID(),
            originalPath: app.url.path,
            trashedPath: trashedAppURL.path,
            size: app.size,
            confidence: .high
        ))

        for file in files {
            try validate(file)
            let trashedURL = try trashService.moveItemToTrash(file.url)
            entries.append(.init(
                id: UUID(),
                originalPath: file.url.path,
                trashedPath: trashedURL.path,
                size: file.size,
                confidence: file.confidence
            ))
        }

        for file in adminFiles {
            try validateAdmin(file)
            let trashedURL = try adminTrashService.moveAdminItemToTrash(file.url, currentUserHome: currentUserHome)
            entries.append(.init(
                id: UUID(),
                originalPath: file.url.path,
                trashedPath: trashedURL.path,
                size: file.size,
                confidence: file.confidence
            ))
        }

        let manifest = DeletionManifest(
            id: UUID(),
            createdAt: Date(),
            appName: app.name,
            bundleIdentifier: app.bundleIdentifier,
            entries: entries
        )
        try manifestStore.save(manifest)
        return manifest
    }

    func moveToTrash(files: [RelatedFile], for app: InstalledApp) throws -> DeletionManifest {
        var entries: [DeletionManifest.Entry] = []

        for file in files {
            try validate(file)
            let trashedURL = try trashService.moveItemToTrash(file.url)
            entries.append(.init(
                id: UUID(),
                originalPath: file.url.path,
                trashedPath: trashedURL.path,
                size: file.size,
                confidence: file.confidence
            ))
        }

        let manifest = DeletionManifest(
            id: UUID(),
            createdAt: Date(),
            appName: app.name,
            bundleIdentifier: app.bundleIdentifier,
            entries: entries
        )
        try manifestStore.save(manifest)
        return manifest
    }

    private func validate(_ app: InstalledApp) throws {
        if app.isAppleSignedOrProtected {
            throw FileDeletionError.protectedApp(app.url)
        }
        if app.isRunning {
            throw FileDeletionError.runningApp(app.name)
        }
        try validatePath(app.url)
    }

    private func validate(_ file: RelatedFile) throws {
        try validatePath(file.url)
        if file.requiresAdmin {
            throw FileDeletionError.requiresAdmin(file.url)
        }
        if file.isSymbolicLink {
            throw FileDeletionError.symbolicLink(file.url)
        }
    }

    private func validateAdmin(_ file: RelatedFile) throws {
        try validatePath(file.url)
        if file.isSymbolicLink {
            throw FileDeletionError.symbolicLink(file.url)
        }
        if !file.isEligibleForAdminRemoval {
            throw FileDeletionError.notAdminEligible(file.url)
        }
    }

    private func validatePath(_ url: URL) throws {
        let path = url.standardizedFileURL.path
        let protectedPrefixes = ["/System", "/bin", "/usr", "/sbin", "/private/etc"]
        if protectedPrefixes.contains(where: { path == $0 || path.hasPrefix($0 + "/") }) {
            throw FileDeletionError.protectedPath(url)
        }
    }
}
