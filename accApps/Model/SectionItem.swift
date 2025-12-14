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
