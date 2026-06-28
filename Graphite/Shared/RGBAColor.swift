import SwiftUI
import AppKit

/// A persistable RGBA color (components 0...1). Bridges SwiftUI `Color`, AppKit
/// `NSColor`, and an "RRGGBBAA" hex string for UserDefaults storage.
struct RGBAColor: Codable, Equatable {
    var red: Double
    var green: Double
    var blue: Double
    var alpha: Double

    init(red: Double, green: Double, blue: Double, alpha: Double = 1) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    /// From a 0xRRGGBB literal with an optional alpha.
    init(rgb: UInt32, alpha: Double = 1) {
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255,
            alpha: alpha
        )
    }

    var color: Color { Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha) }

    var nsColor: NSColor {
        NSColor(srgbRed: red, green: green, blue: blue, alpha: alpha)
    }

    /// Build from a SwiftUI Color via its NSColor bridge (sRGB).
    init(_ color: Color) {
        let ns = NSColor(color).usingColorSpace(.sRGB) ?? .white
        self.init(
            red: Double(ns.redComponent),
            green: Double(ns.greenComponent),
            blue: Double(ns.blueComponent),
            alpha: Double(ns.alphaComponent)
        )
    }

    /// "RRGGBBAA" hex (8 chars). Used for UserDefaults persistence.
    var hexString: String {
        func c(_ v: Double) -> Int { Int((v * 255).rounded()) }
        return String(format: "%02X%02X%02X%02X", c(red), c(green), c(blue), c(alpha))
    }

    /// Parse "RRGGBBAA" (8) or "RRGGBB" (6). Returns nil on malformed input.
    init?(hexString: String) {
        let s = hexString.trimmingCharacters(in: .whitespaces)
        guard let value = UInt32(s, radix: 16) else { return nil }
        switch s.count {
        case 8:
            self.init(
                red: Double((value >> 24) & 0xFF) / 255,
                green: Double((value >> 16) & 0xFF) / 255,
                blue: Double((value >> 8) & 0xFF) / 255,
                alpha: Double(value & 0xFF) / 255
            )
        case 6:
            self.init(rgb: value, alpha: 1)
        default:
            return nil
        }
    }

    /// Blend toward white by `t` (0...1). Used to derive the window gradient's
    /// brighter center stop from the base window color.
    func lightened(by t: Double) -> RGBAColor {
        RGBAColor(
            red: red + (1 - red) * t,
            green: green + (1 - green) * t,
            blue: blue + (1 - blue) * t,
            alpha: alpha
        )
    }
}
