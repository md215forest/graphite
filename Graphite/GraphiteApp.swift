import SwiftUI

@main
struct GraphiteApp: App {
    #if canImport(AppKit)
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif
    @StateObject private var editorState = EditorState()
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
                    #if canImport(AppKit)
                    appDelegate.bind(windowState: windowState)
                    #endif
                    windowState.applyAlwaysOnTop(settingsStore.settings.alwaysOnTop)
                }
        }
        .windowResizability(.contentMinSize)
    }
}
