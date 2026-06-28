import SwiftUI

struct PromptEditorView: View {
    @EnvironmentObject private var editorState: EditorState
    @EnvironmentObject private var windowState: WindowState
    @EnvironmentObject private var settingsStore: SettingsStore

    private let clipboardService = ClipboardService()
    @State private var focusTrigger = 0

    // Hover state for ghost / toolbar controls.
    @State private var hoverAlwaysOnTop = false
    @State private var hoverClear = false
    @State private var hoverCopy = false
    @State private var hoverCopyHide = false

    private var accent: Color { Theme.accent(settingsStore.settings.accent) }
    private var accentSoft: Color { Theme.accentSoft(settingsStore.settings.accent) }
    private var windowOpacity: Double { settingsStore.settings.windowOpacity }
    private var windowBackground: EllipticalGradient {
        Theme.windowGradient(base: settingsStore.settings.windowColor)
    }

    var body: some View {
        VStack(spacing: 0) {
            titleBar
            sheenDivider(0.09)
            editor
            sheenDivider(0.07)
            footer
        }
        .background(windowBackground.opacity(windowOpacity))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.07), lineWidth: 1)
        )
        .overlay(alignment: .top) {
            // inset top highlight: inset 0 1px 0 rgba(255,255,255,0.05)
            Rectangle()
                .fill(Color.white.opacity(0.05))
                .frame(height: 1)
                .padding(.horizontal, 1)
        }
        .overlay(alignment: .bottom) { toast }
        .disabled(windowState.inputBlocked)
        .opacity(windowState.inputBlocked ? 0.6 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: windowState.inputBlocked)
        .ignoresSafeArea()
    }

    // MARK: - Title bar (46px)

    private var titleBar: some View {
        ZStack {
            HStack {
                trafficLights
                Spacer()
            }
            brand
        }
        .padding(.horizontal, 16)
        .frame(height: 40)
    }

    private var trafficLights: some View {
        HStack(spacing: 8) {
            trafficLight(Theme.trafficRed) { windowState.closeWindow() }
            trafficLight(Theme.trafficYellow) { windowState.miniaturize() }
            trafficLight(Theme.trafficGreen) { windowState.zoom() }
        }
    }

    private func trafficLight(_ color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)
                .overlay(
                    Circle().stroke(Color.black.opacity(0.25), lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }

    private var brand: some View {
        HStack(spacing: 9) {
            Hexagon()
                .fill(
                    LinearGradient(
                        colors: [accent, Color(rgb: 0x36383E)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    Hexagon().stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                        .blendMode(.overlay)
                )
                .frame(width: 17, height: 19)
            Text("Graphite")
                .font(Theme.ui(15, .semibold))
                .tracking(0.6)  // 0.04em at 15px
                .foregroundStyle(Theme.wordmark)
        }
    }

    // MARK: - Editor

    private var editor: some View {
        ZStack(alignment: .topLeading) {
            PromptTextView(
                text: $editorState.text,
                accent: accent,
                textColor: settingsStore.settings.textColor.color,
                selectionColor: settingsStore.settings.selectionColor.nsColor,
                focusTrigger: focusTrigger,
                isEditable: !windowState.inputBlocked
            )
            if settingsStore.settings.showTexture {
                PencilGrain()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityLabel("Prompt editor")
    }

    // MARK: - Footer (58px)

    private var footer: some View {
        HStack(spacing: 12) {
            counter
            Spacer()
            alwaysOnTopButton
            clearButton
            separator
            copyButton
            copyHideButton
        }
        .padding(.leading, 18)
        .padding(.trailing, 16)
        .frame(height: 58)
        .background(Theme.footerGradient.opacity(windowOpacity))
    }

    private var counter: some View {
        HStack(spacing: 8) {
            Hexagon()
                .fill(Theme.footerHex)
                .frame(width: 14, height: 16)
            Text(editorState.counterText)
                .font(Theme.mono(11.5))
                .foregroundStyle(Theme.labelMuted)
        }
    }

    private var alwaysOnTopButton: some View {
        Button {
            let next = !settingsStore.settings.alwaysOnTop
            settingsStore.settings.alwaysOnTop = next
            windowState.applyAlwaysOnTop(next)
        } label: {
            HStack(spacing: 7) {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(settingsStore.settings.alwaysOnTop ? accent : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .stroke(Color.white.opacity(0.22), lineWidth: 1.5)
                    )
                    .overlay {
                        if settingsStore.settings.alwaysOnTop {
                            Text("✓")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(Color(rgb: 0x1A1B1F))
                        }
                    }
                    .frame(width: 15, height: 15)
                Text("Always on Top")
                    .font(Theme.ui(12.5))
                    .foregroundStyle(
                        hoverAlwaysOnTop ? Theme.textSecondaryHover : Theme.textSecondary)
            }
        }
        .buttonStyle(.plain)
        .onHover { hoverAlwaysOnTop = $0 }
    }

    private var clearButton: some View {
        Button(action: clear) {
            Text("Clear")
                .font(Theme.ui(12.5))
                .foregroundStyle(hoverClear ? Theme.textSecondaryHover : Theme.textSecondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(Color.white.opacity(hoverClear ? 0.05 : 0))
                )
        }
        .buttonStyle(.plain)
        .onHover { hoverClear = $0 }
    }

    private var separator: some View {
        Rectangle()
            .fill(Color.white.opacity(0.08))
            .frame(width: 1, height: 20)
    }

    private var copyButton: some View {
        Button(action: { copy(andHide: false) }) {
            HStack(spacing: 7) {
                Text("⌘↵")
                    .font(Theme.mono(11))
                    .foregroundStyle(Color(rgb: 0x9296A0))
                Text("Copy")
                    .font(Theme.ui(12.5, .medium))
                    .foregroundStyle(Color(rgb: 0xD2D4D9))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.white.opacity(hoverCopy ? 0.07 : 0.03))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.white.opacity(hoverCopy ? 0.16 : 0.10), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .keyboardShortcut(.return, modifiers: [.command])
        .onHover { hoverCopy = $0 }
    }

    private var copyHideButton: some View {
        Button(action: { copy(andHide: true) }) {
            HStack(spacing: 7) {
                Text("⇧⌘↵")
                    .font(Theme.mono(11))
                    .foregroundStyle(Color(rgb: 0xB7BAC1))
                Text("Copy & Hide")
                    .font(Theme.ui(12.5, .semibold))
                    .foregroundStyle(Color(rgb: 0xF0F1F3))
            }
            .padding(.horizontal, 13)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(hoverCopyHide ? Theme.copyHideGradientHover : Theme.copyHideGradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.white.opacity(0.13), lineWidth: 1)
            )
            .overlay(alignment: .top) {
                Rectangle().fill(accentSoft).frame(height: 1).padding(.horizontal, 1)
            }
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .stroke(Color.white.opacity(0.14), lineWidth: 1)
                    .blur(radius: 0.5)
                    .padding(0.5)
                    .mask(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    .allowsHitTesting(false)
            )
            .shadow(color: .black.opacity(0.4), radius: 1, y: 1)
        }
        .buttonStyle(.plain)
        .keyboardShortcut(.return, modifiers: [.command, .shift])
        .onHover { hoverCopyHide = $0 }
    }

    // MARK: - Toast

    @ViewBuilder
    private var toast: some View {
        if let message = editorState.toast {
            HStack(spacing: 7) {
                Circle().fill(accent).frame(width: 7, height: 7)
                Text(message)
                    .font(Theme.ui(12.5))
                    .foregroundStyle(Theme.textPrimary)
            }
            .padding(.horizontal, 15)
            .padding(.vertical, 9)
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Theme.toastBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.55), radius: 18, y: 14)
            .padding(.bottom, 74)
            .transition(.move(edge: .bottom).combined(with: .opacity))
            .animation(.easeOut(duration: 0.18), value: editorState.toast)
        }
    }

    // MARK: - Dividers

    private func sheenDivider(_ alpha: Double) -> some View {
        Theme.sheen(alpha)
            .frame(height: 1)
    }

    // MARK: - Actions

    private func copy(andHide: Bool) {
        editorState.copy(mode: settingsStore.settings.copyMode, clipboardService: clipboardService)
        editorState.showToast(andHide ? "Copied — window hidden" : "Copied to clipboard")
        if andHide {
            windowState.hideWindow()
        }
    }

    private func clear() {
        editorState.text = ""
        focusTrigger += 1
    }
}
