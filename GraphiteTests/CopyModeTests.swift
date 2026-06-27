import XCTest
@testable import Graphite

final class CopyModeTests: XCTestCase {
    func testRawValuesAreStable() {
        XCTAssertEqual(CopyMode.raw.rawValue, "raw")
        XCTAssertEqual(CopyMode.trimmed.rawValue, "trimmed")
        XCTAssertEqual(CopyMode.codex.rawValue, "codex")
        XCTAssertEqual(CopyMode.githubIssue.rawValue, "githubIssue")
    }

    func testTitlesAreStable() {
        XCTAssertEqual(CopyMode.raw.title, "Raw")
        XCTAssertEqual(CopyMode.trimmed.title, "Trimmed")
        XCTAssertEqual(CopyMode.codex.title, "Codex")
        XCTAssertEqual(CopyMode.githubIssue.title, "Issue")
    }
}
