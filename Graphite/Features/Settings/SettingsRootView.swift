import SwiftUI

enum SettingsTab {
    static let storageKey = "settingsSelectedTab"
    static let appearance = "appearance"
    static let templates = "templates"
}

struct SettingsRootView: View {
    @ObservedObject var settingsStore: SettingsStore
    @AppStorage(SettingsTab.storageKey) private var selectedTab = SettingsTab.appearance
    let windowState: WindowState

    var body: some View {
        TabView(selection: $selectedTab) {
            AppearanceSettingsView(settingsStore: settingsStore)
                .tabItem { Label("Appearance", systemImage: "paintbrush") }
                .tag(SettingsTab.appearance)
            TemplatesSettingsView(settingsStore: settingsStore)
                .tabItem { Label("Templates", systemImage: "doc.text") }
                .tag(SettingsTab.templates)
        }
        .preferredColorScheme(.light)
        .background {
            Color(nsColor: .windowBackgroundColor)
            SettingsWindowConfigurator(windowState: windowState)
        }
        .frame(width: 480, height: 420)
    }
}
