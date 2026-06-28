import SwiftUI

@main
struct GraphiteApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var editorState = EditorState(persistence: .standard)
    @StateObject private var windowState = WindowState()
    @StateObject private var settingsStore = SettingsStore()

    var body: some Scene {
        WindowGroup("Graphite") {
            PromptEditorView()
                .environmentObject(editorState)
                .environmentObject(windowState)
                .environmentObject(settingsStore)
                .frame(minWidth: 520, minHeight: 380)
                .onAppear {
                    appDelegate.bind(windowState: windowState, settingsStore: settingsStore)
                    windowState.applyAlwaysOnTop(settingsStore.settings.alwaysOnTop)
                }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentMinSize)
        .commands {
            SettingsCommands(settingsStore: settingsStore)
        }

        Settings {
            SettingsRootView(settingsStore: settingsStore, windowState: windowState)
        }
    }
}
