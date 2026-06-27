import AppKit
import Carbon.HIToolbox

final class AppDelegate: NSObject, NSApplicationDelegate {
    private weak var windowState: WindowState?
    private var showHotkey: GlobalHotkey?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Running as an unbundled SwiftPM executable (swift run / VSCode) launches
        // as an accessory process, so the window can't become key and keystrokes
        // never reach the editor. Force a regular, activated GUI app.
        NSApp.setActivationPolicy(.regular)
        NSApp.activate(ignoringOtherApps: true)

        if let window = NSApplication.shared.windows.first {
            configure(window: window)
            windowState?.attach(window: window)
        }

        NotificationCenter.default.addObserver(
            forName: NSWindow.didBecomeMainNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let window = notification.object as? NSWindow else { return }
            self?.windowState?.attach(window: window)
        }

        // Global re-show shortcut: ⌘⇧G brings the window back after Copy & Hide.
        showHotkey = GlobalHotkey(
            keyCode: UInt32(kVK_ANSI_G),
            modifiers: UInt32(cmdKey | shiftKey)
        ) { [weak self] in
            self?.windowState?.showWindow()
        }
    }

    func bind(windowState: WindowState) {
        self.windowState = windowState
        if let window = NSApplication.shared.windows.first {
            configure(window: window)
            windowState.attach(window: window)
        }
    }

    /// Frameless / custom-title-bar window per the handoff: 880×600, transparent
    /// titlebar, native traffic lights hidden (we draw our own — the single set
    /// that fixes the duplicate-controls bug), rounded translucent shell.
    private func configure(window: NSWindow) {
        window.title = "Graphite"
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.styleMask.insert(.fullSizeContentView)

        window.standardWindowButton(.closeButton)?.isHidden = true
        window.standardWindowButton(.miniaturizeButton)?.isHidden = true
        window.standardWindowButton(.zoomButton)?.isHidden = true

        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true

        window.setContentSize(NSSize(width: 880, height: 600))
        window.center()
    }
}
