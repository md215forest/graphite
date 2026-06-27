import XCTest
@testable import Graphite

final class CopyModeTests: XCTestCase {
    func testRawValuesAreStable() {
        XCTAssertEqual(CopyMode.raw.rawValue, "raw")
        XCTAssertEqual(CopyMode.trimmed.rawValue, "trimmed")
    }

    func testTitlesAreStable() {
        XCTAssertEqual(CopyMode.raw.title, "Raw")
        XCTAssertEqual(CopyMode.trimmed.title, "Trimmed")
    }
}
