import SwiftUI

struct PromptEditorView: View {
    @EnvironmentObject private var editorState: EditorState
    @EnvironmentObject private var windowState: WindowState
    @EnvironmentObject private var settingsStore: SettingsStore

    private let clipboardService = ClipboardService()
    @State private var showClearConfirmation = false

    var body: some View {
        VStack(spacing: 12) {
            header
            editorContainer
            footer
        }
        .padding(14)
        .background(Color(nsColor: .windowBackgroundColor))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.06), radius: 14, y: 6)
        .alert("Clear Prompt?", isPresented: $showClearConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Clear", role: .destructive) {
                editorState.text = ""
            }
        } message: {
            Text("Current prompt text will be removed.")
        }
    }

    private var header: some View {
        HStack(spacing: 10) {
            Circle().fill(Color(red: 1.0, green: 0.37, blue: 0.34)).frame(width: 12, height: 12)
            Circle().fill(Color(red: 1.0, green: 0.74, blue: 0.2)).frame(width: 12, height: 12)
            Circle().fill(Color(red: 0.17, green: 0.8, blue: 0.36)).frame(width: 12, height: 12)
            Rectangle()
                .fill(Color.gray.opacity(0.28))
                .frame(width: 1, height: 18)
                .padding(.horizontal, 4)
            Text("graphite")
                .font(.system(size: 20 / 2, weight: .medium))
                .foregroundStyle(Color.gray.opacity(0.78))
            Spacer()
        }
        .padding(.horizontal, 2)
        .padding(.bottom, 8)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.gray.opacity(0.16))
                .frame(height: 1)
        }
    }

    private var editorContainer: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Draft your prompt safely before sending")
                .font(.system(size: 30 / 2))
                .foregroundStyle(Color.gray.opacity(0.72))

            PromptTextView(text: $editorState.text)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contextMenu {
                    copyModeMenuItems
                }
                .accessibilityLabel("Prompt editor")
        }
        .padding(14)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var footer: some View {
        HStack(spacing: 14) {
            Label("\(editorState.characterCount) chars  ・  \(editorState.lineCount) lines", systemImage: "doc.text")
                .foregroundStyle(Color.gray.opacity(0.8))

            Toggle("Always on Top", isOn: Binding(
                get: { settingsStore.settings.alwaysOnTop },
                set: {
                    settingsStore.settings.alwaysOnTop = $0
                    windowState.applyAlwaysOnTop($0)
                }
            ))
            .toggleStyle(.checkbox)
            .font(.system(size: 13))
            .foregroundStyle(Color.gray.opacity(0.82))

            Button("Clear") {
                if !editorState.text.isEmpty {
                    showClearConfirmation = true
                }
            }
            .disabled(editorState.text.isEmpty)
            .buttonStyle(.bordered)
            .tint(.gray.opacity(0.35))

            Menu {
                copyModeMenuItems
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 14))
                    .foregroundStyle(Color.gray.opacity(0.65))
            }
            .menuStyle(.borderlessButton)

            Spacer()

            Text("Enter: New line")
            divider
            Button("⌘↩ Copy", action: { copy(andHide: false) })
                .keyboardShortcut(.return, modifiers: [.command])
                .buttonStyle(.plain)
                .foregroundStyle(Color.gray.opacity(0.9))
            divider
            Button("⇧⌘↩ Copy & Hide", action: { copy(andHide: true) })
                .keyboardShortcut(.return, modifiers: [.command, .shift])
                .buttonStyle(.plain)
                .foregroundStyle(Color.gray.opacity(0.9))
        }
        .font(.system(size: 13))
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.92))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var copyModeMenuItems: some View {
        ForEach(CopyMode.allCases) { mode in
            Button {
                settingsStore.settings.copyMode = mode
            } label: {
                if settingsStore.settings.copyMode == mode {
                    Label(mode.title, systemImage: "checkmark")
                } else {
                    Text(mode.title)
                }
            }
        }
    }

    private var divider: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.22))
            .frame(width: 1, height: 14)
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

#Preview {
    PromptEditorView()
        .environmentObject({
            let state = EditorState()
            state.text = """
            Tasklineのプロジェクト登録画面を改善してください。

            要件:
            - ライトトーンではなく落ち着いたトーンにする
            - 余白とタイポグラフィを整理する
            - ボタンの優先度を明確にする
            """
            return state
        }())
        .environmentObject(WindowState())
        .environmentObject(SettingsStore())
        .frame(width: 980, height: 680)
}
