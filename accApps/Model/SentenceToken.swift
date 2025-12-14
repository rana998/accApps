import Foundation

struct SentenceToken: Identifiable, Equatable, Hashable {
    let id: UUID
    var text: String

    init(id: UUID = UUID(), text: String) {
        self.id = id
        self.text = text
    }
}
