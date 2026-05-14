import SwiftUI

struct ToolbarView: View {
    @Binding var copyMode: CopyMode
    @Binding var alwaysOnTop: Bool
    let canClear: Bool
    let onCopy: () -> Void
    let onCopyAndHide: () -> Void
    let onClear: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text("Graphite")
                .font(.headline)

            Spacer()

            Toggle("Always on Top", isOn: $alwaysOnTop)
                .toggleStyle(.switch)

            Picker("Copy Mode", selection: $copyMode) {
                ForEach(CopyMode.allCases) { mode in
                    Text(mode.title).tag(mode)
                }
            }
            .frame(width: 160)

            Button("Copy", action: onCopy)
                .keyboardShortcut(.return, modifiers: [.command])

            Button("Copy & Hide", action: onCopyAndHide)
                .keyboardShortcut(.return, modifiers: [.command, .shift])

            Button("Clear", action: onClear)
                .disabled(!canClear)
        }
        .padding(12)
    }
}
