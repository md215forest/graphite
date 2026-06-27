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

    func testCopiedMessageClearsAfterDelay() {
        let state = EditorState()
        let expectation = expectation(description: "Copied message cleared")

        state.showCopiedMessage(clearAfter: 0.02)
        XCTAssertEqual(state.copiedMessage, "Copied")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.04) {
            XCTAssertNil(state.copiedMessage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1)
    }

    func testCopiedMessageDelayResetsOnConsecutiveCopies() {
        let state = EditorState()
        let stillVisible = expectation(description: "Copied message still visible after first delay")
        let cleared = expectation(description: "Copied message cleared after second delay")

        state.showCopiedMessage(clearAfter: 0.05)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
            state.showCopiedMessage(clearAfter: 0.05)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.07) {
            XCTAssertEqual(state.copiedMessage, "Copied")
            stillVisible.fulfill()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.11) {
            XCTAssertNil(state.copiedMessage)
            cleared.fulfill()
        }

        wait(for: [stillVisible, cleared], timeout: 1)
    }
}
