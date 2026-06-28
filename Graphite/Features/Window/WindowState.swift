import AppKit

final class WindowState: ObservableObject {
    /// True while the Settings window is open; the editor blocks input and dims.
    @Published var inputBlocked: Bool = false

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

    /// Toggle visibility from the activation shortcut: if the window is already the
    /// focused frontmost window, hide it; otherwise summon it to the cursor.
    func toggleWindowAtCursor() {
        guard let window else { return }
        if NSApp.isActive && window.isKeyWindow {
            hideWindow()
        } else {
            showWindowAtCursor()
        }
    }

    /// Re-show and focus the window, e.g. from the global show/hide shortcut.
    func showWindow() {
        NSApp.activate(ignoringOtherApps: true)
        window?.makeKeyAndOrderFront(nil)
    }

    /// Re-show at the mouse cursor: position the window so its top-left sits at
    /// the pointer, clamped to stay fully within the cursor's screen, then focus.
    func showWindowAtCursor() {
        guard let window else { return }
        let cursor = NSEvent.mouseLocation
        let screen = NSScreen.screens.first { NSMouseInRect(cursor, $0.frame, false) }
            ?? NSScreen.main
        window.setFrameTopLeftPoint(clampedTopLeft(for: window, at: cursor, on: screen))
        NSApp.activate(ignoringOtherApps: true)
        window.makeKeyAndOrderFront(nil)
    }

    /// Keep the whole window inside the screen's visible area (excludes menu bar
    /// and Dock). `point` is the desired top-left corner in Cocoa coordinates.
    private func clampedTopLeft(for window: NSWindow, at point: NSPoint, on screen: NSScreen?) -> NSPoint {
        guard let visible = screen?.visibleFrame else { return point }
        let size = window.frame.size
        let minX = visible.minX
        let maxX = visible.maxX - size.width
        let minY = visible.minY + size.height // top-left, so account for height
        let maxY = visible.maxY
        let x = min(max(point.x, minX), max(minX, maxX))
        let y = min(max(point.y, minY), max(minY, maxY))
        return NSPoint(x: x, y: y)
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
