import Foundation

final class RelatedFileScanner {
    private struct SearchLocation {
        let url: URL
        let kind: RelatedFileKind
        let isSystemWide: Bool
        let deepScan: Bool
    }

    private let fileManager: FileManager
    private let classifier: RiskClassifier
    private let homeDirectory: URL

    init(
        fileManager: FileManager = .default,
        classifier: RiskClassifier = RiskClassifier(),
        homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser
    ) {
        self.fileManager = fileManager
        self.classifier = classifier
        self.homeDirectory = homeDirectory
    }

    func scan(for app: InstalledApp) async -> [RelatedFile] {
        await Task.detached(priority: .userInitiated) { [self] in
            let tokens = MatchTokens(appName: app.name, bundleIdentifier: app.bundleIdentifier)
            var results: [RelatedFile] = []
            var seen = Set<URL>()

            for location in searchLocations() where fileManager.fileExists(atPath: location.url.path) {
                let candidates = candidateURLs(in: location)
                for url in candidates {
                    let standardized = url.standardizedFileURL
                    guard seen.insert(standardized).inserted else { continue }
                    guard classifier.isPlausibleMatch(url: standardized, tokens: tokens) else { continue }

                    let isLink = fileManager.isSymbolicLink(at: standardized)
                    let (confidence, reason) = classifier.classify(
                        url: standardized,
                        kind: location.kind,
                        tokens: tokens,
                        isSystemWide: location.isSystemWide,
                        isSymbolicLink: isLink
                    )

                    results.append(RelatedFile(
                        id: standardized,
                        url: standardized,
                        size: fileManager.allocatedSizeOfItem(at: standardized),
                        kind: location.kind,
                        confidence: confidence,
                        reason: reason,
                        requiresAdmin: location.isSystemWide,
                        isSymbolicLink: isLink
                    ))
                }
            }

            return results.sorted {
                if $0.confidence.rawValue != $1.confidence.rawValue {
                    return confidenceRank($0.confidence) < confidenceRank($1.confidence)
                }
                return $0.url.path.localizedCaseInsensitiveCompare($1.url.path) == .orderedAscending
            }
        }.value
    }

    private func searchLocations() -> [SearchLocation] {
        [
            .init(url: homeDirectory.appendingPathComponent("Library/Application Support", isDirectory: true), kind: .applicationSupport, isSystemWide: false, deepScan: false),
            .init(url: homeDirectory.appendingPathComponent("Library/Preferences", isDirectory: true), kind: .preferences, isSystemWide: false, deepScan: false),
            .init(url: homeDirectory.appendingPathComponent("Library/Caches", isDirectory: true), kind: .caches, isSystemWide: false, deepScan: false),
            .init(url: homeDirectory.appendingPathComponent("Library/Logs", isDirectory: true), kind: .logs, isSystemWide: false, deepScan: false),
            .init(url: homeDirectory.appendingPathComponent("Library/Saved Application State", isDirectory: true), kind: .savedState, isSystemWide: false, deepScan: false),
            .init(url: homeDirectory.appendingPathComponent("Library/Containers", isDirectory: true), kind: .containers, isSystemWide: false, deepScan: false),
            .init(url: homeDirectory.appendingPathComponent("Library/Group Containers", isDirectory: true), kind: .groupContainers, isSystemWide: false, deepScan: false),
            .init(url: homeDirectory.appendingPathComponent("Library/LaunchAgents", isDirectory: true), kind: .launchAgent, isSystemWide: false, deepScan: false),
            .init(url: URL(fileURLWithPath: "/Library/Application Support", isDirectory: true), kind: .applicationSupport, isSystemWide: true, deepScan: false),
            .init(url: URL(fileURLWithPath: "/Library/Preferences", isDirectory: true), kind: .preferences, isSystemWide: true, deepScan: false),
            .init(url: URL(fileURLWithPath: "/Library/Caches", isDirectory: true), kind: .caches, isSystemWide: true, deepScan: false),
            .init(url: URL(fileURLWithPath: "/Library/LaunchDaemons", isDirectory: true), kind: .launchDaemon, isSystemWide: true, deepScan: false),
            .init(url: URL(fileURLWithPath: "/Library/PrivilegedHelperTools", isDirectory: true), kind: .privilegedHelper, isSystemWide: true, deepScan: false)
        ]
    }

    private func candidateURLs(in location: SearchLocation) -> [URL] {
        guard location.deepScan else {
            return (try? fileManager.contentsOfDirectory(
                at: location.url,
                includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey, .totalFileAllocatedSizeKey],
                options: [.skipsHiddenFiles]
            )) ?? []
        }

        guard let enumerator = fileManager.enumerator(
            at: location.url,
            includingPropertiesForKeys: [.isDirectoryKey, .isSymbolicLinkKey, .totalFileAllocatedSizeKey],
            options: [.skipsHiddenFiles, .skipsPackageDescendants]
        ) else { return [] }
        return enumerator.compactMap { $0 as? URL }
    }

    private func confidenceRank(_ confidence: FileConfidence) -> Int {
        switch confidence {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}
