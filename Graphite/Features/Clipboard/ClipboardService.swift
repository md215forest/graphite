import AppKit

struct ClipboardService {
    var pasteboard: NSPasteboard = .general

    func copy(_ value: String) {
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
    }
}
