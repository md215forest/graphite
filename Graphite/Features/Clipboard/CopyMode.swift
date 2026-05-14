import Foundation

enum CopyMode: String, CaseIterable, Identifiable {
    case raw
    case trimmed
    case codex
    case githubIssue

    var id: String { rawValue }

    var title: String {
        switch self {
        case .raw: return "Raw"
        case .trimmed: return "Trimmed"
        case .codex: return "Codex"
        case .githubIssue: return "GitHub Issue"
        }
    }
}
