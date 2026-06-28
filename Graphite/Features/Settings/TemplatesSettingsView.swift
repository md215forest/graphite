import SwiftUI

struct TemplatesSettingsView: View {
    @ObservedObject var settingsStore: SettingsStore
    @State private var selection: UUID?

    var body: some View {
        VStack(spacing: 0) {
            List(selection: $selection) {
                ForEach(settingsStore.settings.templates) { template in
                    Text(template.name.isEmpty ? "Untitled" : template.name)
                        .tag(template.id)
                }
            }
            .frame(minHeight: 140)

            HStack(spacing: 6) {
                Button { addTemplate() } label: { Image(systemName: "plus") }
                Button { removeSelected() } label: { Image(systemName: "minus") }
                    .disabled(selection == nil)
                Spacer()
            }
            .buttonStyle(.borderless)
            .padding(6)

            Divider()

            if let binding = selectedBinding() {
                Form {
                    TextField("Name", text: binding.name)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Body").font(.caption).foregroundStyle(.secondary)
                        TextEditor(text: binding.body)
                            .font(.body.monospaced())
                            .frame(minHeight: 120)
                            .border(Color.secondary.opacity(0.3))
                    }
                }
                .formStyle(.grouped)
            } else {
                Spacer()
                Text("Select or add a template")
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
        .padding(12)
    }

    private func addTemplate() {
        let template = Template(name: "New Template", body: "")
        settingsStore.settings.templates.append(template)
        selection = template.id
    }

    private func removeSelected() {
        guard let id = selection else { return }
        settingsStore.settings.templates.removeAll { $0.id == id }
        selection = nil
    }

    /// Binding to the currently selected template, looked up by id each access so
    /// it stays valid as the array mutates.
    private func selectedBinding() -> Binding<Template>? {
        guard let id = selection,
              settingsStore.settings.templates.contains(where: { $0.id == id })
        else { return nil }
        return Binding(
            get: {
                settingsStore.settings.templates.first(where: { $0.id == id }) ?? Template()
            },
            set: { newValue in
                if let idx = settingsStore.settings.templates.firstIndex(where: { $0.id == id }) {
                    settingsStore.settings.templates[idx] = newValue
                }
            }
        )
    }
}
