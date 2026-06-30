import XCTest
@testable import MacAppUninstaller

final class RiskClassifierTests: XCTestCase {
    func testBundleIdentifierMatchIsHighConfidenceInUserLibrary() {
        let classifier = RiskClassifier()
        let tokens = MatchTokens(appName: "Example App", bundleIdentifier: "com.example.app")
        let url = URL(fileURLWithPath: "/Users/test/Library/Caches/com.example.app")

        let result = classifier.classify(url: url, kind: .caches, tokens: tokens, isSystemWide: false, isSymbolicLink: false)

        XCTAssertEqual(result.0, .high)
    }

    func testBundleIdentifierMatchIsMediumConfidenceInSystemLibrary() {
        let classifier = RiskClassifier()
        let tokens = MatchTokens(appName: "Example App", bundleIdentifier: "com.example.app")
        let url = URL(fileURLWithPath: "/Library/Caches/com.example.app")

        let result = classifier.classify(url: url, kind: .caches, tokens: tokens, isSystemWide: true, isSymbolicLink: false)

        XCTAssertEqual(result.0, .medium)
    }

    func testProtectedSystemPathIsLowConfidence() {
        let classifier = RiskClassifier()
        let tokens = MatchTokens(appName: "Example App", bundleIdentifier: "com.example.app")
        let url = URL(fileURLWithPath: "/System/Library/Caches/com.example.app")

        let result = classifier.classify(url: url, kind: .caches, tokens: tokens, isSystemWide: true, isSymbolicLink: false)

        XCTAssertEqual(result.0, .low)
    }
}
