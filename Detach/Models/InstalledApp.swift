import AppKit
import Foundation

struct InstalledApp: Identifiable, Hashable {
    let id: URL
    let url: URL
    let name: String
    let bundleIdentifier: String?
    let version: String?
    let icon: NSImage?
    let size: Int64
    let isAppleSignedOrProtected: Bool
    let isRunning: Bool

    var displayBundleIdentifier: String {
        bundleIdentifier ?? "Unknown bundle identifier"
    }

    var displayVersion: String {
        version?.isEmpty == false ? version! : "Unknown"
    }
}
