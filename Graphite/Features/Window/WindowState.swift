import AppKit

final class WindowState: ObservableObject {
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
}
