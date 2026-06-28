import Foundation

final class SettingsStore: ObservableObject {
    private enum Key {
        static let copyMode = "copyMode"
        static let alwaysOnTop = "alwaysOnTop"
        static let accent = "accent"
        static let showTexture = "showTexture"
        static let activationShortcut = "activationShortcut"
        static let windowOpacity = "windowOpacity"
        static let textColor = "textColor"
        static let windowColor = "windowColor"
        static let selectionColor = "selectionColor"
    }

    private let defaults: UserDefaults

    @Published var settings: AppSettings {
        didSet {
            save(settings)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        settings = AppSettings(
            copyMode: CopyMode(rawValue: defaults.string(forKey: Key.copyMode) ?? "") ?? .raw,
            alwaysOnTop: defaults.object(forKey: Key.alwaysOnTop) as? Bool ?? false,
            accent: AccentColor(rawValue: defaults.string(forKey: Key.accent) ?? "") ?? .silver,
            showTexture: defaults.object(forKey: Key.showTexture) as? Bool ?? true,
            activationShortcut: ActivationShortcut(rawValue: defaults.string(forKey: Key.activationShortcut) ?? "") ?? .rightOption,
            windowOpacity: {
                let value = defaults.object(forKey: Key.windowOpacity) as? Double ?? 1.0
                return min(max(value, AppSettings.opacityRange.lowerBound), AppSettings.opacityRange.upperBound)
            }(),
            textColor: (defaults.string(forKey: Key.textColor).flatMap(RGBAColor.init(hexString:))) ?? RGBAColor(rgb: 0xE6E7EA),
            windowColor: (defaults.string(forKey: Key.windowColor).flatMap(RGBAColor.init(hexString:))) ?? RGBAColor(rgb: 0x191A1D),
            selectionColor: (defaults.string(forKey: Key.selectionColor).flatMap(RGBAColor.init(hexString:))) ?? RGBAColor(rgb: 0xB9BEC8, alpha: 0.22)
        )
    }

    private func save(_ settings: AppSettings) {
        defaults.set(settings.copyMode.rawValue, forKey: Key.copyMode)
        defaults.set(settings.alwaysOnTop, forKey: Key.alwaysOnTop)
        defaults.set(settings.accent.rawValue, forKey: Key.accent)
        defaults.set(settings.showTexture, forKey: Key.showTexture)
        defaults.set(settings.activationShortcut.rawValue, forKey: Key.activationShortcut)
        defaults.set(settings.windowOpacity, forKey: Key.windowOpacity)
        defaults.set(settings.textColor.hexString, forKey: Key.textColor)
        defaults.set(settings.windowColor.hexString, forKey: Key.windowColor)
        defaults.set(settings.selectionColor.hexString, forKey: Key.selectionColor)
    }
}
