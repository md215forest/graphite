import XCTest
@testable import Graphite

final class CounterAndToastTests: XCTestCase {
    func testCounterTextSingularAndPlural() {
        let state = EditorState()

        state.text = ""
        XCTAssertEqual(state.counterText, "0 chars  ·  1 line")

        state.text = "a"
        XCTAssertEqual(state.counterText, "1 char  ·  1 line")

        state.text = "ab\ncd"
        XCTAssertEqual(state.counterText, "5 chars  ·  2 lines")
    }

    func testCounterTextGroupsThousands() {
        let state = EditorState()
        state.text = String(repeating: "x", count: 1234)
        XCTAssertEqual(state.counterText, "1,234 chars  ·  1 line")
    }

    func testToastClearsAfterDelay() {
        let state = EditorState()
        let expectation = expectation(description: "Toast cleared")

        state.showToast("Copied to clipboard", clearAfter: 0.02)
        XCTAssertEqual(state.toast, "Copied to clipboard")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            XCTAssertNil(state.toast)
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
}
