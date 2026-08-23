import Combine
import SwiftUI
import SwiftData

// ViewModel responsible for exposing library content and performing additions
// into the app's persistent store. It keeps UI-free business logic to satisfy MVVM.
final class ACSLibraryPickerViewModel: ObservableObject {
    private let modelContext: ModelContext

    // MARK: - Library data exposed to the views
    @Published var sections: [LibrarySection] = []

    // For UCSView (cards flow): track expanded state per section when browsing cards
    @Published private(set) var expandedSections: Set<UUID> = []

    // For UCSView (cards flow): selected cards per library section
    // Key: LibrarySection.id, Value: Set of LibraryItem.id
    @Published private var selectedItems: [UUID: Set<UUID>] = [:]

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // Load the library content once the sheet appears
    func load() {
        sections = LibraryData.sections
    }

    // MARK: - ACSView (Sections) Flow
    // Add a whole library section and all of its predefined words as cards.
    // If a section with the same name already exists, we reuse it and only add missing cards.
    func addLibrarySection(_ libSection: LibrarySection) throws {
        // Fetch existing sections once to check duplicates
        let descriptor = FetchDescriptor<SectionItem>()
        let existingSections = try modelContext.fetch(descriptor)

        // Create or reuse a SectionItem by name
        let targetSection: SectionItem
        if let found = existingSections.first(where: { $0.name == libSection.name }) {
            targetSection = found
        } else {
            let newSection = SectionItem(
                name: libSection.name,
                colorHex: libSection.colorHex,
                iconName: libSection.iconName
            )
            modelContext.insert(newSection)
            targetSection = newSection
        }

        // Add all predefined words (library items) as cards, skipping duplicates by name
        for item in libSection.items {
            if targetSection.cards.contains(where: { $0.name == item.name }) { continue }
            let card = CardItem(name: item.name, imageData: nil, audioData: nil)
            targetSection.cards.append(card)
        }

        try modelContext.save()
    }

    // MARK: - UCSView (Cards) Flow
    // Expand/collapse library sections when browsing cards to add
    func isSectionExpanded(_ section: LibrarySection) -> Bool {
        expandedSections.contains(section.id)
    }

    func toggleSectionExpanded(_ section: LibrarySection) {
        if expandedSections.contains(section.id) {
            expandedSections.remove(section.id)
        } else {
            expandedSections.insert(section.id)
        }
    }

    // Selection helpers for choosing individual cards to import into UCSView
    func isItemSelected(section: LibrarySection, item: LibraryItem) -> Bool {
        selectedItems[section.id, default: []].contains(item.id)
    }

    func toggleItemSelection(section: LibrarySection, item: LibraryItem) {
        var set = selectedItems[section.id, default: []]
        if set.contains(item.id) {
            set.remove(item.id)
        } else {
            set.insert(item.id)
        }
        selectedItems[section.id] = set
    }

    func selectAllItems(in section: LibrarySection) {
        selectedItems[section.id] = Set(section.items.map { $0.id })
    }

    func deselectAllItems(in section: LibrarySection) {
        selectedItems[section.id] = []
    }

    var canAdd: Bool {
        // Enable Add Selected button only when there is at least one selected card
        !selectedItems.values.allSatisfy { $0.isEmpty } && !selectedItems.isEmpty
    }

    // Import only the selected cards across all library sections into the app's persistent store.
    // This function is intended for UCSView's "Add Selected" action.
    func addSelectedLibraryCards() throws {
        // Pre-fetch sections to place cards into: strategy is to map each library section to an app SectionItem with the same name.
        let descriptor = FetchDescriptor<SectionItem>()
        let existingSections = try modelContext.fetch(descriptor)

        for libSection in sections {
            guard let selected = selectedItems[libSection.id], !selected.isEmpty else { continue }

            // Reuse or create the target SectionItem with the same name as the library section
            let targetSection: SectionItem
            if let found = existingSections.first(where: { $0.name == libSection.name }) {
                targetSection = found
            } else {
                let newSection = SectionItem(
                    name: libSection.name,
                    colorHex: libSection.colorHex,
                    iconName: libSection.iconName
                )
                modelContext.insert(newSection)
                targetSection = newSection
            }

            // Add only the selected library items as cards
            let selectedLibItems = libSection.items.filter { selected.contains($0.id) }
            for item in selectedLibItems {
                if targetSection.cards.contains(where: { $0.name == item.name }) { continue }
                let card = CardItem(name: item.name, imageData: nil, audioData: nil)
                targetSection.cards.append(card)
            }
        }

        try modelContext.save()
    }

    // Optional: clear selection state after a successful import (caller may decide to reset UI)
    func clearSelections() {
        selectedItems.removeAll()
    }
}

