import AppKit
import SwiftUI

struct PromptTextView: NSViewRepresentable {
    @Binding var text: String
    var accent: Color
    var focusTrigger: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(text: $text)
    }

    func makeNSView(context: Context) -> NSScrollView {
        let scrollView = NSScrollView()
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = false
        scrollView.autohidesScrollers = true
        scrollView.drawsBackground = false
        scrollView.borderType = .noBorder
        scrollView.scrollerStyle = .overlay
        scrollView.verticalScroller = GraphiteScroller()

        // Build an explicit TextKit 1 stack. On macOS 13+ a plainly initialized
        // NSTextView defaults to TextKit 2, where — in this hosted/transparent
        // configuration — glyphs are laid out but never painted (the text becomes
        // invisible). Constructing storage → layoutManager → container and using
        // NSTextView(frame:textContainer:) keeps us on the TextKit 1 path that
        // renders correctly.
        let storage = NSTextStorage()
        let layoutManager = NSLayoutManager()
        storage.addLayoutManager(layoutManager)
        let container = NSTextContainer(
            size: NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude))
        container.widthTracksTextView = true
        container.lineFragmentPadding = 0
        layoutManager.addTextContainer(container)

        let textView = GraphiteTextView(
            frame: NSRect(x: 0, y: 0, width: 200, height: 200), textContainer: container)
        textView.isRichText = false
        textView.allowsUndo = true
        // IME safety: keep all auto-substitution off (see refactor-instructions).
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.isContinuousSpellCheckingEnabled = false
        textView.isGrammarCheckingEnabled = false

        let font = Theme.editorNSFont(size: 15)
        textView.font = font
        textView.textColor = NSColor(Theme.textPrimary)
        textView.insertionPointColor = NSColor(accent)
        textView.backgroundColor = .clear
        textView.drawsBackground = false
        // Editor padding 30px (vertical) / 34px (horizontal).
        textView.textContainerInset = NSSize(width: 34, height: 3)
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.autoresizingMask = [.width]
        textView.minSize = NSSize(width: 0, height: 0)
        textView.maxSize = NSSize(
            width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)

        textView.selectedTextAttributes = [
            .backgroundColor: NSColor(
                red: 185 / 255, green: 190 / 255, blue: 200 / 255, alpha: 0.22)
        ]

        textView.defaultParagraphStyle = Self.paragraphStyle
        textView.typingAttributes = Self.attributes(font: font, color: NSColor(Theme.textPrimary))

        textView.delegate = context.coordinator
        scrollView.documentView = textView

        DispatchQueue.main.async {
            textView.window?.makeFirstResponder(textView)
        }
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        textView.insertionPointColor = NSColor(accent)

        if focusTrigger != context.coordinator.lastFocusTrigger {
            context.coordinator.lastFocusTrigger = focusTrigger
            DispatchQueue.main.async {
                textView.window?.makeFirstResponder(textView)
            }
        }

        if textView.string != text {
            textView.string = text
            let range = NSRange(location: 0, length: (text as NSString).length)
            textView.textStorage?.setAttributes(
                Self.attributes(
                    font: textView.font ?? Theme.editorNSFont(), color: NSColor(Theme.textPrimary)),
                range: range
            )
            textView.needsDisplay = true
        }
    }

    private static let paragraphStyle: NSParagraphStyle = {
        let style = NSMutableParagraphStyle()
        style.lineHeightMultiple = 1.2  // editor line-height per the handoff
        return style
    }()

    private static func attributes(font: NSFont, color: NSColor) -> [NSAttributedString.Key: Any] {
        [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle,
            .kern: 0.15,  // letter-spacing 0.01em at 15px
        ]
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String
        var lastFocusTrigger: Int = 0

        init(text: Binding<String>) {
            _text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            text = textView.string
        }
    }
}

/// NSTextView that draws a shorter insertion point. The line-height multiple makes the
/// default caret span the full (tall) line; we match it to the font instead.
final class GraphiteTextView: NSTextView {
    override func drawInsertionPoint(in rect: NSRect, color: NSColor, turnedOn flag: Bool) {
        // The line-height multiple inflates the line box. Match the caret to the font's
        // natural line height and anchor it so it lines up with the text instead of
        // floating in the tall line box.
        var caret = rect
        if let font, let layoutManager {
            let natural = layoutManager.defaultLineHeight(for: font)
            caret.size.height = natural
            // Extra line-height space sits above the glyphs, so the text rides the
            // bottom of the inflated line box — anchor the caret there to match.
            caret.origin.y = rect.maxY - natural
        } else {
            caret.size.height = rect.height / 2
        }
        super.drawInsertionPoint(in: caret, color: color, turnedOn: flag)
    }
}

/// Custom scrollbar: 9px wide, rounded translucent thumb, transparent track.
final class GraphiteScroller: NSScroller {
    override class var isCompatibleWithOverlayScrollers: Bool { true }

    override class func scrollerWidth(
        for controlSize: NSControl.ControlSize,
        scrollerStyle: NSScroller.Style
    ) -> CGFloat {
        9
    }

    override func drawKnobSlot(in slot: NSRect, highlight flag: Bool) {
        // Transparent track.
    }

    override func drawKnob() {
        let knob = rect(for: .knob).insetBy(dx: 2, dy: 2)
        let radius = knob.width / 2
        let path = NSBezierPath(roundedRect: knob, xRadius: radius, yRadius: radius)
        NSColor(white: 1, alpha: 0.08).setFill()
        path.fill()
    }
}
