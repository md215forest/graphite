import AppKit

/// Detects a double-tap of a single modifier key (e.g. Right Option) and fires a
/// callback. It uses `NSEvent` flag-change monitors: a local one (while Graphite
/// is frontmost) and a global one (while another app is). The global monitor only
/// delivers keyboard events once the user grants Input Monitoring permission, so
/// the gesture silently does nothing until then — the ⌘⇧G Carbon hotkey remains
/// the no-permission fallback.
final class DoubleTapMonitor {
    private var globalMonitor: Any?
    private var localMonitor: Any?

    private var mask: NSEvent.ModifierFlags = []
    private let threshold: TimeInterval
    private let action: () -> Void

    private var wasDown = false
    private var lastPress: TimeInterval = 0

    init(shortcut: ActivationShortcut, threshold: TimeInterval = 0.4, action: @escaping () -> Void) {
        self.threshold = threshold
        self.action = action
        update(shortcut: shortcut)
    }

    /// Switch to a new shortcut (or `.off` to stop). Resets tap state.
    func update(shortcut: ActivationShortcut) {
        stop()
        wasDown = false
        lastPress = 0
        guard let mask = shortcut.deviceMask else { return }
        self.mask = mask
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handle(event)
        }
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: .flagsChanged) { [weak self] event in
            self?.handle(event)
            return event
        }
    }

    private func handle(_ event: NSEvent) {
        let down = (event.modifierFlags.rawValue & mask.rawValue) != 0
        defer { wasDown = down }
        // Act only on the press edge (key went from up to down).
        guard down, !wasDown else { return }
        let now = event.timestamp
        if now - lastPress <= threshold {
            lastPress = 0
            action()
        } else {
            lastPress = now
        }
    }

    private func stop() {
        if let globalMonitor { NSEvent.removeMonitor(globalMonitor) }
        if let localMonitor { NSEvent.removeMonitor(localMonitor) }
        globalMonitor = nil
        localMonitor = nil
    }

    deinit { stop() }
}
