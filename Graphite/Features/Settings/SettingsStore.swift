import Foundation

final class SettingsStore: ObservableObject {
    @Published var settings = AppSettings()
}
