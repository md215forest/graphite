import SwiftUI

struct PromptEditorView: View {
    @EnvironmentObject private var editorState: EditorState
    @EnvironmentObject private var windowState: WindowState
    @EnvironmentObject private var settingsStore: SettingsStore

    private let clipboardService = ClipboardService()
    @State private var showClearConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            ToolbarView(
                copyMode: Binding(
                    get: { settingsStore.settings.copyMode },
                    set: { settingsStore.settings.copyMode = $0 }
                ),
                alwaysOnTop: Binding(
                    get: { settingsStore.settings.alwaysOnTop },
                    set: {
                        settingsStore.settings.alwaysOnTop = $0
                        windowState.applyAlwaysOnTop($0)
                    }
                ),
                canClear: !editorState.text.isEmpty,
                onCopy: { copy(andHide: false) },
                onCopyAndHide: { copy(andHide: true) },
                onClear: {
                    if editorState.text.isEmpty {
                        return
                    }
                    showClearConfirmation = true
                }
            )

            PromptTextView(text: $editorState.text)
                .padding(.horizontal, 12)
                .padding(.bottom, 12)

            StatusBarView(
                characters: editorState.characterCount,
                lines: editorState.lineCount,
                copiedMessage: editorState.copiedMessage
            )
        }
        .alert("Clear Prompt?", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                editorState.text = ""
            }
        } message: {
            Text("Current prompt text will be removed.")
        }
    }

    private func copy(andHide: Bool) {
        let output = CopyFormatter.format(editorState.text, mode: settingsStore.settings.copyMode)
        clipboardService.copy(output)
        editorState.copiedMessage = "Copied"

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if editorState.copiedMessage == "Copied" {
                editorState.copiedMessage = nil
            }
        }

        if andHide {
            windowState.hideWindow()
        }
    }
}
