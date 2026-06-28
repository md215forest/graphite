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
        XCTAssertEqual(store.settings.windowOpacity, 1.0)
        XCTAssertEqual(store.settings.textColor, RGBAColor(rgb: 0xE6E7EA))
        XCTAssertEqual(store.settings.windowColor, RGBAColor(rgb: 0x191A1D))
        XCTAssertEqual(store.settings.selectionColor, RGBAColor(rgb: 0xB9BEC8, alpha: 0.22))
    }

    func testNewSettingsPersistAndRestore() {
        let store = SettingsStore(defaults: defaults)
        store.settings.accent = .amber
        store.settings.showTexture = false
        store.settings.windowOpacity = 0.55
        store.settings.textColor = RGBAColor(rgb: 0xFFFFFF)
        store.settings.windowColor = RGBAColor(rgb: 0x101820)
        store.settings.selectionColor = RGBAColor(rgb: 0xB9BEC8, alpha: 0.5)

        let restored = SettingsStore(defaults: defaults)
        XCTAssertEqual(restored.settings.accent, .amber)
        XCTAssertFalse(restored.settings.showTexture)
        XCTAssertEqual(restored.settings.windowOpacity, 0.55)
        XCTAssertEqual(restored.settings.textColor.hexString, "FFFFFFFF")
        XCTAssertEqual(restored.settings.windowColor.hexString, "101820FF")
        XCTAssertEqual(restored.settings.selectionColor.hexString, "B9BEC880")
    }

    func testUnknownAccentFallsBack() {
        defaults.set("neon", forKey: "accent")

        let store = SettingsStore(defaults: defaults)
        XCTAssertEqual(store.settings.accent, .silver)
    }

    func testAppearanceSettingsFallbackAndClamp() {
        defaults.set(0.1, forKey: "windowOpacity")
        defaults.set("not-a-color", forKey: "textColor")
        defaults.set("336699", forKey: "windowColor")
        defaults.set("11223344", forKey: "selectionColor")

        let store = SettingsStore(defaults: defaults)
        XCTAssertEqual(store.settings.windowOpacity, AppSettings.opacityRange.lowerBound)
        XCTAssertEqual(store.settings.textColor, RGBAColor(rgb: 0xE6E7EA))
        XCTAssertEqual(store.settings.windowColor.hexString, "336699FF")
        XCTAssertEqual(store.settings.selectionColor.hexString, "11223344")
    }

    func testTemplatesPersistAndRestore() {
        let store = SettingsStore(defaults: defaults)
        store.settings.templates = [Template(name: "Greeting", body: "Hello")]

        let restored = SettingsStore(defaults: defaults)
        XCTAssertEqual(restored.settings.templates.count, 1)
        XCTAssertEqual(restored.settings.templates.first?.name, "Greeting")
        XCTAssertEqual(restored.settings.templates.first?.body, "Hello")
    }
}
