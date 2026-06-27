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

    /// Re-show and focus the window, e.g. from the global show/hide shortcut.
    func showWindow() {
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    // Custom traffic-light actions (the native buttons are hidden).
    func closeWindow() {
        window?.performClose(nil)
    }

    func miniaturize() {
        window?.miniaturize(nil)
    }

    func zoom() {
        window?.zoom(nil)
    }
}
