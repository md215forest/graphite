import SwiftUI

struct AppearanceSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore
    let windowState: WindowState

    var body: some View {
        Form {
            Section("Window") {
                LabeledContent("Opacity") {
                    Slider(
                        value: Binding(
                            get: { settingsStore.settings.windowOpacity },
                            set: { settingsStore.settings.windowOpacity = $0 }
                        ),
                        in: AppSettings.opacityRange
                    )
                    .frame(width: 200)
                }
                ColorPicker("Color", selection: colorBinding(\.windowColor), supportsOpacity: false)
            }

            Section("Editor") {
                ColorPicker("Text", selection: colorBinding(\.textColor), supportsOpacity: false)
                ColorPicker("Selection", selection: colorBinding(\.selectionColor), supportsOpacity: true)
            }

            Section {
                Button("Reset to Defaults") {
                    let defaults = AppSettings()
                    settingsStore.settings.windowOpacity = defaults.windowOpacity
                    settingsStore.settings.textColor = defaults.textColor
                    settingsStore.settings.windowColor = defaults.windowColor
                    settingsStore.settings.selectionColor = defaults.selectionColor
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background {
            Color(nsColor: .windowBackgroundColor)
            SettingsWindowConfigurator(windowState: windowState)
        }
        .preferredColorScheme(.light)
        .frame(width: 420, height: 340)
    }

    /// Bridge an `RGBAColor` settings field to a `ColorPicker`'s `Color` binding.
    private func colorBinding(_ keyPath: WritableKeyPath<AppSettings, RGBAColor>) -> Binding<Color> {
        Binding(
            get: { settingsStore.settings[keyPath: keyPath].color },
            set: { settingsStore.settings[keyPath: keyPath] = RGBAColor($0) }
        )
    }
}
