import Foundation
import SwiftData

@Model
final class SectionItem {
    var name: String
    var colorHex: String
    var iconName: String
    var createdAt: Date
    var isFavorite: Bool

    // New one-to-many relationship: a section can contain many cards
    var cards: [CardItem] = []

    init(
        name: String,
        colorHex: String,
        iconName: String,
        createdAt: Date = .now,
        isFavorite: Bool = false
    ) {
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.createdAt = createdAt
        self.isFavorite = isFavorite
    }
}

extension SectionItem {
    // Centralized helper: fetch or create the hidden "Default" section
    static func fetchOrCreateDefault(in context: ModelContext) throws -> SectionItem {
        var descriptor = FetchDescriptor<SectionItem>()
        descriptor.predicate = #Predicate { $0.name == "Default" }
        descriptor.fetchLimit = 1
        if let existing = try context.fetch(descriptor).first {
            return existing
        } else {
            let section = SectionItem(
                name: "Default",
                colorHex: "#F5F5F5",
                iconName: "square.stack.3d.up"
            )
            context.insert(section)
            try context.save()
            return section
        }
    }
}
