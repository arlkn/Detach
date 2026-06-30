import XCTest
@testable import MacAppUninstaller

final class RelatedFileEligibilityTests: XCTestCase {
    func testSafeUserFileIsAutomaticAndNotAdminEligible() {
        let file = makeEligibilityFile(
            path: "/Users/test/Library/Caches/com.example.app",
            confidence: .high,
            requiresAdmin: false,
            isSymbolicLink: false
        )

        XCTAssertTrue(file.isSafeForAutomaticRemoval)
        XCTAssertFalse(file.isEligibleForAdminRemoval)
    }

    func testAdminFileIsAdminEligibleAndNotAutomatic() {
        let file = makeEligibilityFile(
            path: "/Library/Caches/com.example.app",
            confidence: .medium,
            requiresAdmin: true,
            isSymbolicLink: false
        )

        XCTAssertFalse(file.isSafeForAutomaticRemoval)
        XCTAssertTrue(file.isEligibleForAdminRemoval)
    }

    func testLowConfidenceAdminFileIsNotEligible() {
        let file = makeEligibilityFile(
            path: "/Library/Caches/example",
            confidence: .low,
            requiresAdmin: true,
            isSymbolicLink: false
        )

        XCTAssertFalse(file.isEligibleForAdminRemoval)
    }

    func testSymbolicLinkAdminFileIsNotEligible() {
        let file = makeEligibilityFile(
            path: "/Library/Caches/com.example.app",
            confidence: .medium,
            requiresAdmin: true,
            isSymbolicLink: true
        )

        XCTAssertFalse(file.isEligibleForAdminRemoval)
    }

    func testProtectedPathIsNotAdminEligible() {
        let file = makeEligibilityFile(
            path: "/System/Library/Caches/com.example.app",
            confidence: .medium,
            requiresAdmin: true,
            isSymbolicLink: false
        )

        XCTAssertFalse(file.isEligibleForAdminRemoval)
    }
}

private func makeEligibilityFile(
    path: String,
    confidence: FileConfidence,
    requiresAdmin: Bool,
    isSymbolicLink: Bool
) -> RelatedFile {
    RelatedFile(
        id: URL(fileURLWithPath: path),
        url: URL(fileURLWithPath: path),
        size: 1,
        kind: .caches,
        confidence: confidence,
        reason: "Test",
        requiresAdmin: requiresAdmin,
        isSymbolicLink: isSymbolicLink
    )
}
