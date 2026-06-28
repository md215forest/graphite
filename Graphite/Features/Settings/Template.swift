import Foundation

/// A reusable prompt template: a name and the body inserted into the editor.
struct Template: Identifiable, Equatable, Codable {
    var id: UUID = UUID()
    var name: String = ""
    var body: String = ""
}
