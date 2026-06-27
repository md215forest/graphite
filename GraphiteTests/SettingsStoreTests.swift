import XCTest
@testable import Graphite

final class SettingsStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "GraphiteTests.SettingsStore.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testDefaultsWhenNothingIsSaved() {
        let store = SettingsStore(defaults: defaults)

        XCTAssertEqual(store.settings.copyMode, .raw)
        XCTAssertFalse(store.settings.alwaysOnTop)
    }

    func testPersistsAndRestoresSettings() {
        let store = SettingsStore(defaults: defaults)

        store.settings.copyMode = .trimmed
        store.settings.alwaysOnTop = true

        let restored = SettingsStore(defaults: defaults)
        XCTAssertEqual(restored.settings.copyMode, .trimmed)
        XCTAssertTrue(restored.settings.alwaysOnTop)
    }

    func testUnknownCopyModeFallsBackToRaw() {
        defaults.set("futureMode", forKey: "copyMode")
        defaults.set(true, forKey: "alwaysOnTop")

        let store = SettingsStore(defaults: defaults)

        XCTAssertEqual(store.settings.copyMode, .raw)
        XCTAssertTrue(store.settings.alwaysOnTop)
    }
}
