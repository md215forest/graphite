import SwiftUI
#if canImport(AppKit)
import AppKit

struct PromptTextView: NSViewRepresentable {
    @Binding var text: String

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

        let textView = NSTextView()
        textView.isRichText = false
        textView.allowsUndo = true
        textView.isAutomaticQuoteSubstitutionEnabled = false
        textView.isAutomaticDashSubstitutionEnabled = false
        textView.isAutomaticTextReplacementEnabled = false
        textView.isAutomaticSpellingCorrectionEnabled = false
        textView.font = .monospacedSystemFont(ofSize: 26 / 2, weight: .regular)
        textView.textColor = NSColor(calibratedWhite: 0.15, alpha: 1.0)
        textView.backgroundColor = .clear
        textView.textContainerInset = NSSize(width: 8, height: 12)
        textView.isHorizontallyResizable = false
        textView.isVerticallyResizable = true
        textView.textContainer?.widthTracksTextView = true
        textView.textContainer?.containerSize = NSSize(width: 0, height: CGFloat.greatestFiniteMagnitude)
        textView.delegate = context.coordinator

        scrollView.documentView = textView
        scrollView.hasVerticalRuler = true
        scrollView.rulersVisible = true
        scrollView.verticalRulerView = LineNumberRulerView(scrollView: scrollView, textView: textView)
        return scrollView
    }

    func updateNSView(_ nsView: NSScrollView, context: Context) {
        guard let textView = nsView.documentView as? NSTextView else { return }
        if textView.string != text {
            textView.string = text
        }
    }

    final class Coordinator: NSObject, NSTextViewDelegate {
        @Binding var text: String

        init(text: Binding<String>) {
            _text = text
        }

        func textDidChange(_ notification: Notification) {
            guard let textView = notification.object as? NSTextView else { return }
            text = textView.string
            if let ruler = textView.enclosingScrollView?.verticalRulerView as? LineNumberRulerView {
                ruler.needsDisplay = true
            }
        }
    }
}
#else
struct PromptTextView: View {
    @Binding var text: String

    var body: some View {
        TextEditor(text: $text)
            .font(.system(size: 13, design: .monospaced))
    }
}
#endif

private final class LineNumberRulerView: NSRulerView {
    private let lineNumberAttributes: [NSAttributedString.Key: Any] = [
        .font: NSFont.monospacedSystemFont(ofSize: 12, weight: .regular),
        .foregroundColor: NSColor(calibratedWhite: 0.62, alpha: 1.0)
    ]

    init(scrollView: NSScrollView, textView: NSTextView) {
        super.init(scrollView: scrollView, orientation: .verticalRuler)
        clientView = textView
        ruleThickness = 44
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawHashMarksAndLabels(in rect: NSRect) {
        guard let textView = clientView as? NSTextView,
              let layoutManager = textView.layoutManager,
              let textContainer = textView.textContainer else {
            return
        }

        NSColor(calibratedWhite: 0.97, alpha: 1.0).setFill()
        bounds.fill()

        let visibleGlyphRange = layoutManager.glyphRange(forBoundingRect: textView.visibleRect, in: textContainer)
        let firstVisibleCharacterIndex = layoutManager.characterIndexForGlyph(at: visibleGlyphRange.location)
        var lineNumber = (textView.string[..<textView.string.index(textView.string.startIndex, offsetBy: min(firstVisibleCharacterIndex, textView.string.count))]
            .filter { $0 == "\n" }.count) + 1

        var glyphIndex = visibleGlyphRange.location
        while glyphIndex < NSMaxRange(visibleGlyphRange) {
            var lineRange = NSRange()
            let lineRect = layoutManager.lineFragmentRect(forGlyphAt: glyphIndex, effectiveRange: &lineRange, withoutAdditionalLayout: true)
            let y = lineRect.minY + textView.textContainerInset.height
            let label = "\(lineNumber)" as NSString
            let size = label.size(withAttributes: lineNumberAttributes)
            let x = ruleThickness - size.width - 10
            label.draw(at: NSPoint(x: x, y: y), withAttributes: lineNumberAttributes)
            glyphIndex = NSMaxRange(lineRange)
            lineNumber += 1
        }
    }
}
