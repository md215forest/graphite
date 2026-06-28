import AppKit
import SwiftUI

/// Zero-size helper view that grabs the Settings window and (a) gives it normal
/// chrome with a close button, (b) tags it so AppDelegate won't apply the editor's
/// custom styling, and (c) toggles `windowState.inputBlocked` while it is open.
struct SettingsWindowConfigurator: NSViewRepresentable {
    let windowState: WindowState

    func makeCoordinator() -> Coordinator { Coordinator(windowState: windowState) }

    func makeNSView(context: Context) -> NSView {
        let view = NSView(frame: .zero)
        DispatchQueue.main.async { context.coordinator.attach(to: view.window) }
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        DispatchQueue.main.async { context.coordinator.attach(to: nsView.window) }
    }

    final class Coordinator {
        private let windowState: WindowState
        private weak var window: NSWindow?
        private var tokens: [NSObjectProtocol] = []

        init(windowState: WindowState) { self.windowState = windowState }

        func attach(to window: NSWindow?) {
            guard let window, self.window !== window else { return }
            self.window = window

            // Tag so the global styling observer skips this window.
            window.identifier = NSUserInterfaceItemIdentifier(WindowID.settings)

            // Normalize to a standard light window with a close button. (Restores
            // anything the global observer may have stripped -- order-independent.)
            window.titleVisibility = .visible
            window.titlebarAppearsTransparent = false
            window.styleMask.remove(.fullSizeContentView)
            window.styleMask.insert(.titled)
            window.styleMask.insert(.closable)
            window.isOpaque = true
            window.backgroundColor = .windowBackgroundColor
            window.standardWindowButton(.closeButton)?.isHidden = false
            window.hasShadow = true

            // While open, block editor input; restore on close.
            let center = NotificationCenter.default
            tokens.forEach(center.removeObserver)
            tokens.removeAll()
            tokens.append(center.addObserver(
                forName: NSWindow.didBecomeKeyNotification,
                object: window,
                queue: .main
            ) { [weak self] _ in self?.windowState.inputBlocked = true })
            tokens.append(center.addObserver(
                forName: NSWindow.willCloseNotification,
                object: window,
                queue: .main
            ) { [weak self] _ in self?.windowState.inputBlocked = false })

            // It is key right now (just opened).
            windowState.inputBlocked = true
        }

        deinit { tokens.forEach(NotificationCenter.default.removeObserver) }
    }
}
