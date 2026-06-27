import Foundation

enum CopyFormatter {
    static func format(_ text: String, mode: CopyMode) -> String {
        switch mode {
        case .raw:
            return text
        case .trimmed:
            return text.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}
