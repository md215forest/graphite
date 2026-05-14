import Foundation

final class EditorState: ObservableObject {
    @Published var text: String = ""
    @Published var copiedMessage: String?

    var characterCount: Int { text.count }

    var lineCount: Int {
        guard !text.isEmpty else { return 1 }
        return text.components(separatedBy: .newlines).count
    }
}
