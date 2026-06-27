import Foundation

enum AccentColor: String, CaseIterable, Identifiable {
    case silver
    case steel
    case amber

    var id: String { rawValue }

    var title: String {
        switch self {
        case .silver: return "Silver"
        case .steel: return "Steel"
        case .amber: return "Amber"
        }
    }
}

enum EnterKeyMode: String, CaseIterable, Identifiable {
    case newline
    case send

    var id: String { rawValue }

    var title: String {
        switch self {
        case .newline: return "New line"
        case .send: return "Copy"
        }
    }

    // Footer hint text, per the handoff Behavior section.
    var hint: String {
        switch self {
        case .newline: return "Enter for new line"
        case .send: return "Enter to copy"
        }
    }
}

struct AppSettings {
    var copyMode: CopyMode = .raw
    var alwaysOnTop: Bool = false
    var accent: AccentColor = .silver
    var showTexture: Bool = true
    var enterKey: EnterKeyMode = .newline
}
