import XCTest
@testable import Graphite

final class CopyFormatterTests: XCTestCase {
    func testRawModePreservesInput() {
        XCTAssertEqual(CopyFormatter.format("", mode: .raw), "")
        XCTAssertEqual(CopyFormatter.format("  hello  \n", mode: .raw), "  hello  \n")
        XCTAssertEqual(CopyFormatter.format("a\nb", mode: .raw), "a\nb")
    }

    func testTrimmedModeRemovesOnlyLeadingAndTrailingWhitespaceAndNewlines() {
        XCTAssertEqual(CopyFormatter.format("", mode: .trimmed), "")
        XCTAssertEqual(CopyFormatter.format("   \n\t", mode: .trimmed), "")
        XCTAssertEqual(CopyFormatter.format("  hello  \n", mode: .trimmed), "hello")
        XCTAssertEqual(CopyFormatter.format("  a\nb  ", mode: .trimmed), "a\nb")
    }
}
