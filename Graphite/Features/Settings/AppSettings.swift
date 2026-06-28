import AppKit

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

/// A modifier key whose double-tap re-shows the window at the cursor. This is a
/// global gesture, so it relies on an `NSEvent` monitor (and thus Input
/// Monitoring permission) while another app is frontmost. The ⌘⇧G Carbon hotkey
/// stays available as a no-permission fallback that works on any keyboard.
enum ActivationShortcut: String, CaseIterable, Identifiable {
    case off
    case rightOption
    case leftOption
    case rightCommand
    case leftCommand
    case fn

    var id: String { rawValue }

    var title: String {
        switch self {
        case .off: return "Off"
        case .rightOption: return "Right Option (double-tap)"
        case .leftOption: return "Left Option (double-tap)"
        case .rightCommand: return "Right Command (double-tap)"
        case .leftCommand: return "Left Command (double-tap)"
        case .fn: return "Fn (double-tap)"
        }
    }

    /// The bit that flips in `NSEvent.modifierFlags.rawValue` when this physical
    /// key is pressed/released. Left/right variants use device-dependent masks so
    /// the two sides can be told apart. `nil` disables the monitor.
    var deviceMask: NSEvent.ModifierFlags? {
        switch self {
        case .off: return nil
        case .leftOption: return NSEvent.ModifierFlags(rawValue: 0x0000_0020)  // NX_DEVICELALTKEYMASK
        case .rightOption: return NSEvent.ModifierFlags(rawValue: 0x0000_0040)  // NX_DEVICERALTKEYMASK
        case .leftCommand: return NSEvent.ModifierFlags(rawValue: 0x0000_0008)  // NX_DEVICELCMDKEYMASK
        case .rightCommand: return NSEvent.ModifierFlags(rawValue: 0x0000_0010)  // NX_DEVICERCMDKEYMASK
        case .fn: return .function
        }
    }
}

struct AppSettings {
    var copyMode: CopyMode = .raw
    var alwaysOnTop: Bool = false
    var accent: AccentColor = .silver
    var showTexture: Bool = true
    var activationShortcut: ActivationShortcut = .rightOption
    // Appearance
    var windowOpacity: Double = 1.0
    var textColor: RGBAColor = RGBAColor(rgb: 0xE6E7EA)
    var windowColor: RGBAColor = RGBAColor(rgb: 0x191A1D)
    var selectionColor: RGBAColor = RGBAColor(rgb: 0xB9BEC8, alpha: 0.22)
    var templates: [Template] = []
}

extension AppSettings {
    static let opacityRange: ClosedRange<Double> = 0.3...1.0
}
