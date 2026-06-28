import SwiftUI

/// The settings entries shared by the in-app overflow (⋯) menu and the macOS
/// menu-bar "Settings" command menu, so both stay in sync from one definition.
struct SettingsMenuItems: View {
    @ObservedObject var settingsStore: SettingsStore

    var body: some View {
        Menu("Copy Format") {
            ForEach(CopyMode.allCases) { mode in
                Button {
                    settingsStore.settings.copyMode = mode
                } label: {
                    if settingsStore.settings.copyMode == mode {
                        Label(mode.title, systemImage: "checkmark")
                    } else {
                        Text(mode.title)
                    }
                }
            }
        }
        Menu("Accent") {
            ForEach(AccentColor.allCases) { color in
                Button {
                    settingsStore.settings.accent = color
                } label: {
                    if settingsStore.settings.accent == color {
                        Label(color.title, systemImage: "checkmark")
                    } else {
                        Text(color.title)
                    }
                }
            }
        }
        Menu("Show at Cursor") {
            ForEach(ActivationShortcut.allCases) { shortcut in
                Button {
                    settingsStore.settings.activationShortcut = shortcut
                } label: {
                    if settingsStore.settings.activationShortcut == shortcut {
                        Label(shortcut.title, systemImage: "checkmark")
                    } else {
                        Text(shortcut.title)
                    }
                }
            }
        }
        Toggle(
            "Show Texture",
            isOn: Binding(
                get: { settingsStore.settings.showTexture },
                set: { settingsStore.settings.showTexture = $0 }
            ))
    }
}

/// Places the settings entries inside the app ("Graphite") menu, just under
/// the Services menu.
struct SettingsCommands: Commands {
    @ObservedObject var settingsStore: SettingsStore

    var body: some Commands {
        CommandGroup(after: .systemServices) {
            Divider()
            SettingsMenuItems(settingsStore: settingsStore)
        }
    }
}
