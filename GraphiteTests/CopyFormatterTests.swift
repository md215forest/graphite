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

    func testCodexModeReturnsEmptyForBlankInput() {
        XCTAssertEqual(CopyFormatter.format("", mode: .codex), "")
        XCTAssertEqual(CopyFormatter.format("   \n\t", mode: .codex), "")
    }

    func testCodexModeWrapsTrimmedBodyInTemplate() {
        let expected = """
        # 目的

        a
        b

        # 制約

        - 既存の挙動を壊さないでください
        - 変更範囲を必要最小限にしてください

        # 確認方法

        - 実装後に確認方法を提示してください
        """

        XCTAssertEqual(CopyFormatter.format("  a\nb  ", mode: .codex), expected)
    }

    func testGitHubIssueModeWrapsOriginalTextInTemplate() {
        let expected = """
        ## 概要

          a
        b  

        ## 対応内容

        -

        ## 受け入れ条件

        -

        ## 確認方法

        -
        """

        XCTAssertEqual(CopyFormatter.format("  a\nb  ", mode: .githubIssue), expected)
    }
}
