import Foundation
import SwiftUI
import SwiftData

extension Notification.Name {
    static let cardWordSelected = Notification.Name("cardWordSelected")
}

private struct Chip: Identifiable, Hashable {
    let id = UUID()
    let text: String
    // Optional tint hex captured from the section; if nil, we’ll fall back to a default.
    let colorHex: String?
}

struct ACSView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var lock: LockState
    // Fetch all sections, newest first
    @Query(sort: \SectionItem.createdAt, order: .reverse) private var sections: [SectionItem]

    @State private var isPageLocked = false
    @State private var isPressed = false
    @State private var addCard: Bool = false
    @State private var editCard: Bool = false
    @Namespace private var animation

    // Delete selection mode (Photos-like)
    @State private var isSelecting = false
    @State private var showDeleteConfirm = false
    @State private var selectedSectionIDs = Set<PersistentIdentifier>()

    // Edit selection mode (Photos-like flow for editing)
    @State private var isEditSelecting = false

    // Selected section for editing
    @State private var currentlySelectedSection: SectionItem? = nil

    // Settings: change level confirmation + navigation
    @State private var showChangeLevelAlert = false
    @State private var navigateToTargetUsers = false

    @AppStorage(LastRouteKey.key) private var lastRouteRaw: String = Route.ucs.rawValue

    // Chips collected from SectionDetailView taps
    @State private var chips: [Chip] = []

    // Show sheet with all words when Done is tapped
    @State private var showWordsSheet = false

    // Grid layout for sections
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 180), spacing: 16)
    ]

    // When star is ON, sort favorites to the front; otherwise, use the default order from @Query
    private var displayedSections: [SectionItem] {
        guard isPressed else { return sections }
        return sections.sorted { lhs, rhs in
            if lhs.isFavorite == rhs.isFavorite {
                return false
            }
            return lhs.isFavorite && !rhs.isFavorite
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Hidden navigation trigger to TargetUsers after confirmation
                    NavigationLink("", isActive: $navigateToTargetUsers) { TargetUsers() }
                        .hidden()

                    // Title area
                    VStack(spacing: 12) {
                        Text("Choose From The Menu")
                            .font(.custom("Rubik-SemiBold", size: 36))
                            .foregroundColor(.darkBlue)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                            .padding(.top, 12)

                        // Thin divider (fixed width 830)
                        Rectangle()
                            .fill(Color.primary.opacity(0.1))
                            .frame(width: 830, height: 1)

                        // Inline chip bar right under the divider (fixed width 830)
                        inlineChipBar
                            .frame(width: 830, alignment: .trailing)
                            .padding(.top, 2)
                    }
                    .padding(.bottom, 8)

                    // Sections grid
                    if displayedSections.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "square.grid.2x2")
                                .font(.system(size: 36, weight: .regular))
                                .foregroundColor(.secondary)
                            Text("No sections yet")
                                .font(.custom("Rubik-Medium", size: 18))
                                .foregroundColor(.secondary)
                            Text("Tap + to add your first section.")
                                .font(.custom("Rubik-Regular", size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 26) {
                                ForEach(displayedSections) { section in
                                    let isSelectedForDelete = selectedSectionIDs.contains(section.persistentModelID)
                                    let isSelectedForEdit = currentlySelectedSection?.persistentModelID == section.persistentModelID

                                    if isSelecting || isEditSelecting {
                                        // Selection/edit modes: do NOT wrap in NavigationLink. Handle tap explicitly.
                                        sectionCard(
                                            section,
                                            isInEditSelection: isEditSelecting,
                                            isSelectedForEdit: isSelectedForEdit,
                                            isInDeleteSelection: isSelecting,
                                            isSelectedForDelete: isSelectedForDelete
                                        )
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            guard !isPageLocked else { return }
                                            if isSelecting {
                                                toggleDeleteSelection(section)
                                            } else if isEditSelecting {
                                                currentlySelectedSection = section
                                                editCard = true
                                            }
                                        }
                                        // Keep disabled only for delete-selection if you still want to block other gestures.
                                        .disabled(isSelecting)
                                    } else {
                                        // Normal mode: NavigationLink for navigation to detail
                                        NavigationLink {
                                            SectionDetailView(section: section)
                                        } label: {
                                            sectionCard(
                                                section,
                                                isInEditSelection: false,
                                                isSelectedForEdit: false,
                                                isInDeleteSelection: false,
                                                isSelectedForDelete: false
                                            )
                                        }
                                        // No simultaneousGesture; NavigationLink owns the tap in normal mode.
                                        .disabled(isSelecting) // should be false here, but keep consistent
                                    }
                                }
                            }
                            .padding(.horizontal, 26)
                            .padding(.vertical, 16)
                        }
                    }

                    Spacer(minLength: 0)

                    // Bottom "Done" button
                    Button {
                        showWordsSheet = true
                    } label: {
                        Text("Done")
                            .font(.custom("Rubik-SemiBold", size: 20))
                            .foregroundColor(.darkBlue)
                            .frame(maxWidth: 320)
                            .padding(.vertical, 14)
                            .background(
                                Capsule()
                                    .fill(Color.lightBlue.opacity(0.9))
                                    .shadow(color: .black.opacity(0.06), radius: 12, x: 0, y: 6)
                            )
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.6), lineWidth: 0.5)
                            )
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 22)
                }
                .padding(.horizontal, 16)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                if isEditSelecting {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            isEditSelecting = false
                            currentlySelectedSection = nil
                        }
                        .font(.custom("Rubik-Medium", size: 20))
                        .foregroundColor(.darkBlue)
                        .disabled(isPageLocked || lock.isLocked)
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            isEditSelecting = false
                            currentlySelectedSection = nil
                        }
                        .font(.custom("Rubik-Medium", size: 20))
                        .foregroundColor(.darkBlue)
                        .disabled(isPageLocked || lock.isLocked)
                    }
                } else if isSelecting {
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            exitDeleteSelectionMode()
                        }
                        .font(.custom("Rubik-Medium", size: 20))
                        .foregroundColor(.darkBlue)
                        .disabled(isPageLocked || lock.isLocked)
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showDeleteConfirm = true
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(selectedSectionIDs.isEmpty ? .secondary : .red)
                        }
                        .disabled(isPageLocked || lock.isLocked || selectedSectionIDs.isEmpty)
                    }
                } else {
                    ToolbarItem(id: "Lock", placement: .topBarTrailing){
                        Button{
                            isPageLocked.toggle()
                            lock.isLocked = isPageLocked
                            if isPageLocked {
                                isEditSelecting = false
                                exitDeleteSelectionMode()
                                currentlySelectedSection = nil
                            }
                        } label: {
                            Image(systemName: isPageLocked ? "lock" : "lock.open")
                                .font(.custom("Rubik-Medium", size: 20))
                                .foregroundColor(.darkBlue)
                        }
                    }

                    ToolbarItem(id: "Star", placement: .topBarTrailing){
                        Button{
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isPressed.toggle()
                            }
                        } label: {
                            Image(systemName: isPressed ? "star.fill" :"star")
                                .foregroundColor(isPressed ? .orange : .darkBlue)
                                .font(.custom("Rubik-Medium", size: 20))
                        }
                        .disabled(isPageLocked || lock.isLocked)
                    }

                    ToolbarItem(id: "Settings", placement: .topBarTrailing){
                        Menu {
                            Button {
                                showChangeLevelAlert = true
                            } label: {
                                Label("Change Level", systemImage: "slider.horizontal.3")
                            }
                        } label: {
                            Image(systemName: "gear")
                                .font(.custom("Rubik-Medium", size: 20))
                                .foregroundColor(.darkBlue)
                        }
                        .matchedTransitionSource(id: "Settings", in: animation)
                        .disabled(isPageLocked || lock.isLocked)
                    }

                    ToolbarItem(id: "Edit", placement: .topBarTrailing){
                        Button{
                            isEditSelecting = true
                            currentlySelectedSection = nil
                        } label: {
                            Image(systemName: "pencil")
                                .font(.custom("Rubik-Medium", size: 20))
                                .foregroundColor(.darkBlue)
                        }
                        .disabled(isPageLocked || lock.isLocked)
                    }

                    ToolbarItem(id: "Add", placement: .topBarTrailing){
                        Button{
                            addCard.toggle()
                        } label: {
                            Image(systemName: "plus")
                                .font(.custom("Rubik-Medium", size: 20))
                                .foregroundColor(.darkBlue)
                        }
                        .disabled(isPageLocked || lock.isLocked)
                    }

                    ToolbarSpacer(.fixed, placement: .topBarTrailing)

                    ToolbarItem(id: "Select", placement: .topBarTrailing){
                        Button {
                            isSelecting = true
                            isEditSelecting = false
                            selectedSectionIDs.removeAll()
                            currentlySelectedSection = nil
                        } label: {
                            Text("Select")
                                .font(.custom("Rubik-Medium", size: 20))
                                .foregroundColor(.darkBlue)
                        }
                        .disabled(isPageLocked || lock.isLocked)
                    }
                }
            }
            .confirmationDialog(
                "Delete Permanently?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    performDeleteSelectedSections()
                    exitDeleteSelectionMode()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This action can’t be undone.")
            }
            .alert("All data will be deleted permanently", isPresented: $showChangeLevelAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Change Level", role: .destructive) {
                    deleteAllDataAndNavigate()
                }
            } message: {
                Text("This action cannot be undone.")
            }
            .sheet(isPresented: $addCard){
                AddSectionView()
                    .navigationTransition(.zoom(sourceID: "Add", in: animation))
                    .presentationDetents([.height(420)]) // white sheet smaller (explicit)
            }
            .sheet(isPresented: $editCard){
                if let section = currentlySelectedSection {
                    EditSectionView(section: section)
                        .navigationTransition(.zoom(sourceID: "Edit", in: animation))
                        .presentationDetents([.height(420)]) // white sheet smaller (explicit)
                } else {
                    Text("Select a section to edit")
                        .font(.custom("Rubik-Medium", size: 18))
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            // Combined sentence sheet when tapping bottom Done
            .sheet(isPresented: $showWordsSheet) {
                CombinedSentenceView(
                    words: chips.map { $0.text },
                    onClose: { showWordsSheet = false }
                )
                .presentationDetents([.height(500)])   // blue sheet larger (explicit)
                .presentationDragIndicator(.hidden)     // remove grabber for a cleaner look
            }
            .onAppear {
                isPageLocked = lock.isLocked
            }
            // Receive tapped word from SectionDetailView
            .onReceive(NotificationCenter.default.publisher(for: .cardWordSelected)) { note in
                guard let word = note.userInfo?["word"] as? String else { return }
                let trimmed = word.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !trimmed.isEmpty else { return }

                // Optional color from the posting view
                let colorHex = note.userInfo?["colorHex"] as? String

                // Allow duplicates: always append a new Chip with a unique id
                chips.append(Chip(text: trimmed, colorHex: colorHex))
            }
        }
    }

    // MARK: - Inline Chip Bar (clear background, fixed width 830, no search icon)
    private var inlineChipBar: some View {
        HStack(spacing: 8) {
            ChipsRow(chips: $chips)

            if !chips.isEmpty {
                Button("Clear") {
                    chips.removeAll()
                }
                .font(.custom("Rubik-Medium", size: 14))
                .foregroundColor(.darkBlue)
            }
        }
        .padding(.horizontal, 4)
        .padding(.vertical, 6)
        .background(Color.clear)
    }

    // MARK: - Section Card
    @ViewBuilder
    private func sectionCard(
        _ section: SectionItem,
        isInEditSelection: Bool,
        isSelectedForEdit: Bool,
        isInDeleteSelection: Bool,
        isSelectedForDelete: Bool
    ) -> some View {
        let tint = Color(hex: section.colorHex) ?? .lightBlue

        VStack(spacing: 10) {
            ZStack(alignment: .topTrailing) {
                // Circle with icon
                ZStack {
                    Circle()
                        .fill(tint)
                        .frame(width: 100, height: 100)
                        .glassEffect(.regular.interactive())

                    Image(systemName: section.iconName.isEmpty ? "questionmark" : section.iconName)
                        .font(.system(size: 44, weight: .semibold))
                        .foregroundStyle(.black.opacity(0.3))
                }

                // Per-section favorite toggle
                Button {
                    section.isFavorite.toggle()
                    try? modelContext.save()
                } label: {
                    Image(systemName: section.isFavorite ? "star.fill" : "star")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(section.isFavorite ? .orange : .darkBlue.opacity(0.7))
                        .padding(6)
                        .background(
                            Circle()
                                .fill(tint.opacity(0.7))
                        )
                }
                .buttonStyle(.plain)
                .offset(x: 45, y: -30)
                .disabled(isPageLocked || lock.isLocked)

                if isInDeleteSelection {
                    ZStack {
                        Circle()
                            .fill(isSelectedForDelete ? Color.blue : Color.white.opacity(0.9))
                            .overlay(
                                Circle().stroke(Color.blue, lineWidth: 2)
                            )
                        if isSelectedForDelete {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .frame(width: 22, height: 22)
                    .offset(x: -120, y: -24)
                    .transition(.scale)
                    .allowsHitTesting(false)
                }
            }

            Text(section.name)
                .font(.custom("Rubik-Medium", size: 16))
                .foregroundColor(.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding(15)
        .frame(width: 200, height: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(tint.opacity(0.7))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
        .overlay(
            Group {
                if isInEditSelection && isSelectedForEdit {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.darkBlue.opacity(0.7), lineWidth: 2)
                } else if isInDeleteSelection && isSelectedForDelete {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.8), lineWidth: 2)
                }
            }
        )
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 17))
        .padding()
    }

    // MARK: - Delete selection helpers
    private func toggleDeleteSelection(_ section: SectionItem) {
        let id = section.persistentModelID
        if selectedSectionIDs.contains(id) {
            selectedSectionIDs.remove(id)
        } else {
            selectedSectionIDs.insert(id)
        }
    }

    private func exitDeleteSelectionMode() {
        isSelecting = false
        selectedSectionIDs.removeAll()
    }

    private func performDeleteSelectedSections() {
        guard !selectedSectionIDs.isEmpty else { return }
        let toDelete = sections.filter { selectedSectionIDs.contains($0.persistentModelID) }
        toDelete.forEach { modelContext.delete($0) }
        do {
            try modelContext.save()
        } catch {
            print("Failed to delete selected sections: \(error)")
        }
    }

    // MARK: - Data deletion + navigation (Change Level)
    private func deleteAllDataAndNavigate() {
        do {
            let allCardsDescriptor = FetchDescriptor<CardItem>()
            let allCards = try modelContext.fetch(allCardsDescriptor)
            allCards.forEach { modelContext.delete($0) }

            sections.forEach { modelContext.delete($0) }

            try modelContext.save()
        } catch {
            print("Failed to delete all data: \(error)")
        }
        navigateToTargetUsers = true
    }
}

// MARK: - Extracted subviews

private struct ChipPill: View {
    let chip: Chip
    let onRemove: () -> Void

    private var tint: Color {
        if let hex = chip.colorHex, let c = Color(hex: hex) {
            return c
        }
        return .lightBlue // fallback
    }

    var body: some View {
        HStack(spacing: 6) {
            Text(chip.text)
                .font(.custom("Rubik-Medium", size: 14))
                .foregroundColor(.darkBlue)
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(tint.opacity(0.85))
        )
        .overlay(
            Capsule()
                .stroke(Color.black.opacity(0.08), lineWidth: 0.5)
        )
        .glassEffect(.regular.interactive())
    }
}

private struct ChipsRow: View {
    @Binding var chips: [Chip]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(chips) { chip in
                    ChipPill(chip: chip) {
                        chips.removeAll { $0.id == chip.id }
                    }
                }
            }
            .padding(.vertical, 6)
        }
    }
}

// MARK: - Words sheet

private struct WordsSheetView: View {
    let words: [String]
    var onClear: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if words.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "text.bubble")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        Text("No words yet")
                            .font(.custom("Rubik-Medium", size: 16))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 24)
                } else {
                    List {
                        ForEach(words, id: \.self) { w in
                            Text(w)
                                .font(.custom("Rubik-Medium", size: 18))
                                .foregroundColor(.primary)
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Your Words")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if !words.isEmpty {
                        Button("Clear All") {
                            onClear()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ACSView()
}
