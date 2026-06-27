import XCTest
@testable import Graphite

final class DraftPersistenceTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "GraphiteTests.Draft.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testDraftPersistsAndRestores() {
        let state = EditorState(persistence: defaults)
        state.text = "remember me\nacross launches"

        let restored = EditorState(persistence: defaults)
        XCTAssertEqual(restored.text, "remember me\nacross launches")
    }

    func testPlainStateDoesNotPersist() {
        // No persistence injected -> draft must not leak into the suite.
        let state = EditorState()
        state.text = "scratch"

        let restored = EditorState(persistence: defaults)
        XCTAssertEqual(restored.text, "")
    }
}
