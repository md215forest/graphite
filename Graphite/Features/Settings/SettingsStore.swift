import Foundation

final class SettingsStore: ObservableObject {
    private enum Key {
        static let copyMode = "copyMode"
        static let alwaysOnTop = "alwaysOnTop"
        static let accent = "accent"
        static let showTexture = "showTexture"
        static let activationShortcut = "activationShortcut"
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
            activationShortcut: ActivationShortcut(rawValue: defaults.string(forKey: Key.activationShortcut) ?? "") ?? .rightOption
        )
    }

    private func save(_ settings: AppSettings) {
        defaults.set(settings.copyMode.rawValue, forKey: Key.copyMode)
        defaults.set(settings.alwaysOnTop, forKey: Key.alwaysOnTop)
        defaults.set(settings.accent.rawValue, forKey: Key.accent)
        defaults.set(settings.showTexture, forKey: Key.showTexture)
        defaults.set(settings.activationShortcut.rawValue, forKey: Key.activationShortcut)
    }
}
