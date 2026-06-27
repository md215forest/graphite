import Foundation
#if canImport(AppKit)
import AppKit
#endif

final class WindowState: ObservableObject {
    #if canImport(AppKit)
    private weak var window: NSWindow?

    func attach(window: NSWindow) {
        self.window = window
    }

    func applyAlwaysOnTop(_ enabled: Bool) {
        window?.level = enabled ? .floating : .normal
    }

    func hideWindow() {
        window?.orderOut(nil)
    }
    #else
    func applyAlwaysOnTop(_ enabled: Bool) {
        _ = enabled
    }

    func hideWindow() {}
    #endif
}
