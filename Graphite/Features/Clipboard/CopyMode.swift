import Foundation

enum CopyMode: String, CaseIterable, Identifiable {
    case raw
    case trimmed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .raw: return "Raw"
        case .trimmed: return "Trimmed"
        }
    }
}
