import Foundation

final class EditorState: ObservableObject {
    @Published var text: String {
        didSet { persistDraft() }
    }
    @Published var copiedMessage: String?
    @Published var toast: String?

    private var clearCopiedMessageWorkItem: DispatchWorkItem?
    private var clearToastWorkItem: DispatchWorkItem?

    private let persistence: UserDefaults?
    private static let draftKey = "draftText"

    /// `persistence` is opt-in so unit tests can use a plain, non-persisting state.
    init(persistence: UserDefaults? = nil) {
        self.persistence = persistence
        self.text = persistence?.string(forKey: EditorState.draftKey) ?? ""
    }

    var characterCount: Int { text.count }

    var lineCount: Int {
        guard !text.isEmpty else { return 1 }
        return text.components(separatedBy: .newlines).count
    }

    // Footer counter, e.g. "1,234 chars  ·  5 lines" (singular at count 1).
    var counterText: String {
        let chars = EditorState.grouped(characterCount)
        let charUnit = characterCount == 1 ? "char" : "chars"
        let lineUnit = lineCount == 1 ? "line" : "lines"
        return "\(chars) \(charUnit)  ·  \(lineCount) \(lineUnit)"
    }

    private static let groupingFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.usesGroupingSeparator = true
        return formatter
    }()

    private static func grouped(_ value: Int) -> String {
        groupingFormatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    @discardableResult
    func copy(
        mode: CopyMode,
        clipboardService: ClipboardService = ClipboardService(),
        feedbackDelay: TimeInterval = 1.2
    ) -> String {
        let output = CopyFormatter.format(text, mode: mode)
        clipboardService.copy(output)
        showCopiedMessage(clearAfter: feedbackDelay)
        return output
    }

    func showCopiedMessage(clearAfter delay: TimeInterval = 1.2) {
        clearCopiedMessageWorkItem?.cancel()
        copiedMessage = "Copied"

        let workItem = DispatchWorkItem { [weak self] in
            self?.copiedMessage = nil
        }
        clearCopiedMessageWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    func showToast(_ message: String, clearAfter delay: TimeInterval = 1.6) {
        clearToastWorkItem?.cancel()
        toast = message

        let workItem = DispatchWorkItem { [weak self] in
            self?.toast = nil
        }
        clearToastWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func persistDraft() {
        persistence?.set(text, forKey: EditorState.draftKey)
    }
}
