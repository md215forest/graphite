import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    private weak var windowState: WindowState?

    func applicationDidFinishLaunching(_ notification: Notification) {
        if let window = NSApplication.shared.windows.first {
            window.title = "Graphite"
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
    }

    func bind(windowState: WindowState) {
        self.windowState = windowState
        if let window = NSApplication.shared.windows.first {
            windowState.attach(window: window)
        }
    }
}
