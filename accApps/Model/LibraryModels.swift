import Foundation

public struct LibraryItem: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let imageSystemName: String?

    public init(id: UUID = UUID(), name: String, imageSystemName: String? = nil) {
        self.id = id
        self.name = name
        self.imageSystemName = imageSystemName
    }
}

public struct LibrarySection: Identifiable, Hashable {
    public let id: UUID
    public let name: String
    public let iconName: String
    public let colorHex: String
    public let items: [LibraryItem]

    public init(id: UUID = UUID(), name: String, iconName: String, colorHex: String, items: [LibraryItem]) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.items = items
    }
}

public enum LibraryData {
    public static var sections: [LibrarySection] {
        [
            LibrarySection(
                name: "الأكل",
                iconName: "fork.knife",
                colorHex: "#FF6F61",
                items: [
                    LibraryItem(name: "خبز"),
                    LibraryItem(name: "رز"),
                    LibraryItem(name: "دجاج"),
                    LibraryItem(name: "بيض"),
                    LibraryItem(name: "جبن"),
                    LibraryItem(name: "تفاح"),
                    LibraryItem(name: "موز"),
                    LibraryItem(name: "بسكويت"),
                    LibraryItem(name: "حليب"),
                    LibraryItem(name: "عصير")
                ]
            ),
            LibrarySection(
                name: "المشاعر",
                iconName: "face.smiling",
                colorHex: "#4A90E2",
                items: [
                    LibraryItem(name: "سعيد"),
                    LibraryItem(name: "حزين"),
                    LibraryItem(name: "غاضب"),
                    LibraryItem(name: "مندهش")
                ]
            )
        ]
    }
}
