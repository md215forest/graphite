import SwiftUI
import AppKit

// Design tokens recreated from design_handoff_graphite/README.md.
// Values (colors, spacing, typography) are kept literal so the handoff
// numbers can be cross-checked against this file directly.
enum Theme {
    // MARK: Accent

    static func accent(_ accent: AccentColor) -> Color {
        switch accent {
        case .silver: return Color(rgb: 0xB9BEC8)
        case .steel: return Color(rgb: 0x92A8C6)
        case .amber: return Color(rgb: 0xD8B27A)
        }
    }

    static func accentSoft(_ accent: AccentColor) -> Color {
        switch accent {
        case .silver: return Color(red: 185 / 255, green: 190 / 255, blue: 200 / 255, opacity: 0.32)
        case .steel: return Color(red: 146 / 255, green: 168 / 255, blue: 198 / 255, opacity: 0.34)
        case .amber: return Color(red: 216 / 255, green: 178 / 255, blue: 122 / 255, opacity: 0.34)
        }
    }

    // MARK: Surfaces & lines

    static let textPrimary = Color(rgb: 0xE6E7EA)
    static let wordmark = Color(rgb: 0xE9EAED)
    static let textSecondary = Color(rgb: 0x9A9DA4)
    static let textSecondaryHover = Color(rgb: 0xC6C8CD)
    static let label = Color(rgb: 0x65686F)
    static let labelMuted = Color(rgb: 0x6F727A)
    static let placeholder = Color(rgb: 0x5A5D65)

    static let trafficRed = Color(rgb: 0xEC6A5E)
    static let trafficYellow = Color(rgb: 0xF3BD4F)
    static let trafficGreen = Color(rgb: 0x61C454)

    static let hairline = Color.white.opacity(0.08)
    static let footerHex = Color(rgb: 0x4A4D54)

    static let windowGradient = EllipticalGradient(
        stops: [
            .init(color: Color(rgb: 0x232427), location: 0.0),
            .init(color: Color(rgb: 0x191A1D), location: 0.58)
        ],
        center: UnitPoint(x: 0.5, y: -0.12),
        startRadiusFraction: 0,
        endRadiusFraction: 0.85
    )

    static let footerGradient = LinearGradient(
        colors: [Color(rgb: 0x171819), Color(rgb: 0x141517)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let copyHideGradient = LinearGradient(
        colors: [Color(rgb: 0x3B3E45), Color(rgb: 0x2A2C31)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let copyHideGradientHover = LinearGradient(
        colors: [Color(rgb: 0x474A52), Color(rgb: 0x33353B)],
        startPoint: .top,
        endPoint: .bottom
    )

    static let toastBackground = Color(rgb: 0x26282D)

    // Sheen divider used under the title bar / above the footer.
    static func sheen(_ alpha: Double) -> LinearGradient {
        LinearGradient(
            stops: [
                .init(color: .clear, location: 0.04),
                .init(color: Color.white.opacity(alpha), location: 0.5),
                .init(color: .clear, location: 0.96)
            ],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    // MARK: Typography
    // Hanken Grotesk (UI) and JetBrains Mono (editor/numerals) per the handoff.
    // If the user does not have them installed we fall back to the closest
    // system faces so the app still renders cleanly offline.

    private static let hasHanken = NSFont(name: "Hanken Grotesk", size: 12) != nil
    private static let hasJetBrains = NSFont(name: "JetBrains Mono", size: 12) != nil

    static func ui(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        if hasHanken {
            return Font.custom("Hanken Grotesk", fixedSize: size).weight(weight)
        }
        return Font.system(size: size, weight: weight)
    }

    static func mono(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
        if hasJetBrains {
            return Font.custom("JetBrains Mono", fixedSize: size).weight(weight)
        }
        return Font.system(size: size, weight: weight, design: .monospaced)
    }

    static func editorNSFont(size: CGFloat = 15) -> NSFont {
        NSFont(name: "JetBrains Mono", size: size)
            ?? .monospacedSystemFont(ofSize: size, weight: .regular)
    }
}

extension Color {
    init(rgb: UInt32) {
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}

// Hexagonal graphite mark: clip-path polygon(50% 0,100% 25%,100% 75%,50% 100%,0 75%,0 25%).
struct Hexagon: Shape {
    func path(in rect: CGRect) -> Path {
        let w = rect.width
        let h = rect.height
        var path = Path()
        path.move(to: CGPoint(x: 0.5 * w, y: 0))
        path.addLine(to: CGPoint(x: w, y: 0.25 * h))
        path.addLine(to: CGPoint(x: w, y: 0.75 * h))
        path.addLine(to: CGPoint(x: 0.5 * w, y: h))
        path.addLine(to: CGPoint(x: 0, y: 0.75 * h))
        path.addLine(to: CGPoint(x: 0, y: 0.25 * h))
        path.closeSubpath()
        return path
    }
}

// Faint diagonal "pencil grain":
// repeating-linear-gradient(132deg, rgba(255,255,255,0.02) 0 1px, transparent 1px 8px), opacity 0.6.
struct PencilGrain: View {
    var body: some View {
        Canvas { context, size in
            let spacing: CGFloat = 8
            let lineColor = Color.white.opacity(0.02)
            // 132deg from the x-axis; draw lines along that direction by
            // stepping perpendicular to it across the whole canvas.
            let angle = Angle(degrees: 132).radians
            let dir = CGVector(dx: cos(angle), dy: sin(angle))
            let normal = CGVector(dx: -dir.dy, dy: dir.dx)
            let diagonal = sqrt(size.width * size.width + size.height * size.height)
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            var offset = -diagonal
            while offset <= diagonal {
                let base = CGPoint(
                    x: center.x + normal.dx * offset,
                    y: center.y + normal.dy * offset
                )
                var line = Path()
                line.move(to: CGPoint(x: base.x - dir.dx * diagonal, y: base.y - dir.dy * diagonal))
                line.addLine(to: CGPoint(x: base.x + dir.dx * diagonal, y: base.y + dir.dy * diagonal))
                context.stroke(line, with: .color(lineColor), lineWidth: 1)
                offset += spacing
            }
        }
        .opacity(0.6)
        .allowsHitTesting(false)
    }
}
