import XCTest
@testable import Graphite

final class SettingsStoreExtendedTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!

    override func setUp() {
        super.setUp()
        suiteName = "GraphiteTests.SettingsStoreExtended.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)
        defaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testNewSettingsDefaults() {
        let store = SettingsStore(defaults: defaults)
        XCTAssertEqual(store.settings.accent, .silver)
        XCTAssertTrue(store.settings.showTexture)
        XCTAssertEqual(store.settings.enterKey, .newline)
    }

    func testNewSettingsPersistAndRestore() {
        let store = SettingsStore(defaults: defaults)
        store.settings.accent = .amber
        store.settings.showTexture = false
        store.settings.enterKey = .send

        let restored = SettingsStore(defaults: defaults)
        XCTAssertEqual(restored.settings.accent, .amber)
        XCTAssertFalse(restored.settings.showTexture)
        XCTAssertEqual(restored.settings.enterKey, .send)
    }

    func testUnknownAccentAndEnterKeyFallBack() {
        defaults.set("neon", forKey: "accent")
        defaults.set("teleport", forKey: "enterKey")

        let store = SettingsStore(defaults: defaults)
        XCTAssertEqual(store.settings.accent, .silver)
        XCTAssertEqual(store.settings.enterKey, .newline)
    }
}
