import AppKit
import Foundation

final class AppScanner {
    private let fileManager: FileManager
    private let applicationDirectories: [URL]

    init(fileManager: FileManager = .default, homeDirectory: URL = FileManager.default.homeDirectoryForCurrentUser) {
        self.fileManager = fileManager
        self.applicationDirectories = [
            URL(fileURLWithPath: "/Applications", isDirectory: true),
            homeDirectory.appendingPathComponent("Applications", isDirectory: true)
        ]
    }

    func scan() async -> [InstalledApp] {
        await Task.detached(priority: .userInitiated) { [fileManager, applicationDirectories] in
            var apps: [InstalledApp] = []

            for directory in applicationDirectories where fileManager.fileExists(atPath: directory.path) {
                guard let enumerator = fileManager.enumerator(
                    at: directory,
                    includingPropertiesForKeys: [.isDirectoryKey, .isApplicationKey, .totalFileAllocatedSizeKey],
                    options: [.skipsHiddenFiles, .skipsPackageDescendants]
                ) else { continue }

                while let next = enumerator.nextObject() {
                    guard let url = next as? URL, url.pathExtension == "app" else { continue }
                    guard let bundle = Bundle(url: url) else { continue }
                    let name = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
                        ?? bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
                        ?? url.deletingPathExtension().lastPathComponent
                    let bundleID = bundle.bundleIdentifier
                    let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
                    let icon = NSWorkspace.shared.icon(forFile: url.path)
                    let size = fileManager.allocatedSizeOfItem(at: url)
                    let protected = Self.isProtectedAppleApp(url: url, bundleIdentifier: bundleID)
                    let running = NSWorkspace.shared.runningApplications.contains { runningApp in
                        runningApp.bundleURL?.standardizedFileURL == url.standardizedFileURL
                    }

                    apps.append(InstalledApp(
                        id: url,
                        url: url,
                        name: name,
                        bundleIdentifier: bundleID,
                        version: version,
                        icon: icon,
                        size: size,
                        isAppleSignedOrProtected: protected,
                        isRunning: running
                    ))
                }
            }

            return apps.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        }.value
    }

    private static func isProtectedAppleApp(url: URL, bundleIdentifier: String?) -> Bool {
        if url.path.hasPrefix("/System/") { return true }
        if bundleIdentifier?.hasPrefix("com.apple.") == true { return true }

        let protectedNames: Set<String> = [
            "App Store", "Automator", "Calendar", "Contacts", "Finder", "Launchpad",
            "Mail", "Messages", "Music", "Photos", "Preview", "Safari", "System Settings",
            "Terminal", "TextEdit", "Time Machine"
        ]
        return protectedNames.contains(url.deletingPathExtension().lastPathComponent)
    }
}
