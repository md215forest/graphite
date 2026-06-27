import Foundation
#if canImport(AppKit)
import AppKit
#endif

struct ClipboardService {
    func copy(_ value: String) {
        #if canImport(AppKit)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
        #else
        _ = value
        #endif
    }
}
