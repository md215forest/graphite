import Foundation

final class EditorState: ObservableObject {
    @Published var text: String = ""
    @Published var copiedMessage: String?
    private var clearCopiedMessageWorkItem: DispatchWorkItem?

    var characterCount: Int { text.count }

    var lineCount: Int {
        guard !text.isEmpty else { return 1 }
        return text.components(separatedBy: .newlines).count
    }

    @discardableResult
    func copy(
        mode: CopyMode,
        clipboardService: ClipboardService = ClipboardService(),
        feedbackDelay: TimeInterval = 1.5
    ) -> String {
        let output = CopyFormatter.format(text, mode: mode)
        clipboardService.copy(output)
        showCopiedMessage(clearAfter: feedbackDelay)
        return output
    }

    func showCopiedMessage(clearAfter delay: TimeInterval = 1.5) {
        clearCopiedMessageWorkItem?.cancel()
        copiedMessage = "Copied"

        let workItem = DispatchWorkItem { [weak self] in
            self?.copiedMessage = nil
        }
        clearCopiedMessageWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}
