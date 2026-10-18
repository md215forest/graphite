import AppKit
import XCTest
@testable import Graphite

final class CopyHistoryTests: XCTestCase {
    private var pasteboard: NSPasteboard!
    private var clipboard: ClipboardService!
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        pasteboard = NSPasteboard.withUniqueName()
        clipboard = ClipboardService(pasteboard: pasteboard)
        suiteName = "GraphiteTests.History.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
    }

    override func tearDown() {
        pasteboard.releaseGlobally()
        defaults.removePersistentDomain(forName: suiteName)
        super.tearDown()
    }

    func testCopyKeepsOnlyTenMostRecentEntriesAcrossLaunches() {
        let state = EditorState(persistence: defaults)
        for index in 1...12 {
            state.text = "Entry \(index)"
            state.copy(mode: .raw, clipboardService: clipboard)
        }

        let expected = (3...12).reversed().map { "Entry \($0)" }
        XCTAssertEqual(state.copyHistory, expected)
        XCTAssertEqual(EditorState(persistence: defaults).copyHistory, expected)
    }

    func testCopyPreservesOriginalEditorTextWhenClipboardIsTrimmed() {
        let state = EditorState()
        state.text = "  日本語😀\nsecond line\n"
        let output = state.copy(mode: .trimmed, clipboardService: clipboard)

        XCTAssertEqual(output, "日本語😀\nsecond line")
        XCTAssertEqual(pasteboard.string(forType: .string), output)
        XCTAssertEqual(state.copyHistory, [state.text])
    }

    func testEachCopyIsRecordedIncludingDuplicatesAndEmptyText() {
        let state = EditorState()
        state.text = "Repeated"
        state.copy(mode: .raw, clipboardService: clipboard)
        state.copy(mode: .raw, clipboardService: clipboard)
        state.text = ""
        state.copy(mode: .raw, clipboardService: clipboard)

        XCTAssertEqual(state.copyHistory, ["", "Repeated", "Repeated"])
        XCTAssertTrue(EditorState(persistence: defaults).copyHistory.isEmpty)
    }

    func testEditingOrRestoringTextDoesNotRecordHistory() {
        let state = EditorState(persistence: defaults)
        state.text = "Saved"
        state.copy(mode: .raw, clipboardService: clipboard)
        state.text = "Other draft"
        state.text = state.copyHistory[0]

        XCTAssertEqual(state.copyHistory, ["Saved"])
    }
}
