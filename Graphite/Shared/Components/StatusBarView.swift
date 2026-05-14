import SwiftUI

struct StatusBarView: View {
    let characters: Int
    let lines: Int
    let copiedMessage: String?

    var body: some View {
        HStack {
            Text("\(characters) chars / \(lines) lines")
                .foregroundStyle(.secondary)

            Spacer()

            Text(KeyboardShortcutHint.newline)
                .foregroundStyle(.secondary)

            Divider().frame(height: 12)

            Text(KeyboardShortcutHint.copy)
                .foregroundStyle(.secondary)

            Divider().frame(height: 12)

            Text(KeyboardShortcutHint.copyAndHide)
                .foregroundStyle(.secondary)

            if let copiedMessage {
                Divider().frame(height: 12)
                Text(copiedMessage)
                    .foregroundStyle(.green)
                    .fontWeight(.semibold)
            }
        }
        .font(.system(size: 12))
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(.bar)
    }
}
