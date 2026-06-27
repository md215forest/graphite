import Foundation

final class SettingsStore: ObservableObject {
    private enum Key {
        static let copyMode = "copyMode"
        static let alwaysOnTop = "alwaysOnTop"
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
            alwaysOnTop: defaults.object(forKey: Key.alwaysOnTop) as? Bool ?? false
        )
    }

    private func save(_ settings: AppSettings) {
        defaults.set(settings.copyMode.rawValue, forKey: Key.copyMode)
        defaults.set(settings.alwaysOnTop, forKey: Key.alwaysOnTop)
    }
}
