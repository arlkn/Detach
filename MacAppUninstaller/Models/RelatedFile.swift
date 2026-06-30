import Foundation

enum FileConfidence: String, CaseIterable, Codable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}

enum RelatedFileKind: String, Codable {
    case applicationSupport = "Application Support"
    case preferences = "Preferences"
    case caches = "Caches"
    case logs = "Logs"
    case savedState = "Saved State"
    case containers = "Containers"
    case groupContainers = "Group Containers"
    case launchAgent = "Launch Agent"
    case launchDaemon = "Launch Daemon"
    case privilegedHelper = "Privileged Helper"
    case unknown = "Unknown"
}

struct RelatedFile: Identifiable, Hashable {
    let id: URL
    let url: URL
    let size: Int64
    let kind: RelatedFileKind
    let confidence: FileConfidence
    let reason: String
    let requiresAdmin: Bool
    let isSymbolicLink: Bool

    var isSelectedByDefault: Bool {
        confidence != .low && !requiresAdmin
    }

    var isSafeForAutomaticRemoval: Bool {
        confidence != .low && !requiresAdmin && !isSymbolicLink
    }

    var isEligibleForAdminRemoval: Bool {
        requiresAdmin
        && confidence != .low
        && !isSymbolicLink
        && !isProtectedSystemPath
    }

    var isProtectedSystemPath: Bool {
        let path = url.standardizedFileURL.path
        let protectedPrefixes = ["/System", "/bin", "/usr", "/sbin", "/private/etc"]
        return protectedPrefixes.contains { path == $0 || path.hasPrefix($0 + "/") }
    }
}
