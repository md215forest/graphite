import XCTest
@testable import Graphite

final class EditorStateTests: XCTestCase {
    func testLineCountMatchesCurrentBoundaries() {
        let state = EditorState()

        state.text = ""
        XCTAssertEqual(state.lineCount, 1)

        state.text = "a"
        XCTAssertEqual(state.lineCount, 1)

        state.text = "a\nb"
        XCTAssertEqual(state.lineCount, 2)

        state.text = "a\n"
        XCTAssertEqual(state.lineCount, 2)
    }

    func testCharacterCountUsesSwiftStringCount() {
        let state = EditorState()

        state.text = "abc"
        XCTAssertEqual(state.characterCount, 3)

        state.text = "a😀b"
        XCTAssertEqual(state.characterCount, 3)
    }
}
