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

struct AppSettings {
    var copyMode: CopyMode = .raw
    var alwaysOnTop: Bool = false
    var accent: AccentColor = .silver
    var showTexture: Bool = true
}
