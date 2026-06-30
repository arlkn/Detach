import XCTest
@testable import MacAppUninstaller

final class RelatedFileScannerTests: XCTestCase {
    func testPlausibleMatchRejectsUnrelatedFile() {
        let classifier = RiskClassifier()
        let tokens = MatchTokens(appName: "Example App", bundleIdentifier: "com.example.app")
        let unrelated = URL(fileURLWithPath: "/Users/test/Library/Caches/org.other.product")

        XCTAssertFalse(classifier.isPlausibleMatch(url: unrelated, tokens: tokens))
    }

    func testPlausibleMatchAcceptsBundleIdentifier() {
        let classifier = RiskClassifier()
        let tokens = MatchTokens(appName: "Example App", bundleIdentifier: "com.example.app")
        let related = URL(fileURLWithPath: "/Users/test/Library/Preferences/com.example.app.plist")

        XCTAssertTrue(classifier.isPlausibleMatch(url: related, tokens: tokens))
    }

    func testNameOnlyMatchDoesNotBecomeHighConfidence() {
        let classifier = RiskClassifier()
        let tokens = MatchTokens(appName: "Example App", bundleIdentifier: nil)
        let related = URL(fileURLWithPath: "/Users/test/Library/Application Support/Example App")

        let result = classifier.classify(url: related, kind: .applicationSupport, tokens: tokens, isSystemWide: false, isSymbolicLink: false)

        XCTAssertEqual(result.0, .medium)
    }
}
