import Foundation
import SwiftUI
import SwiftData

struct UCSView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var lock: LockState

    // Fetch all cards, newest first
    @Query(sort: \CardItem.createdAt, order: .reverse) private var cards: [CardItem]

    // Toolbar states (mirroring SectionDetailView behavior)
    @State private var isPressed = false // prioritize favorites when true
    @Namespace private var animation

    // Delete-selection mode for cards (Photos-like)
    @State private var isSelecting = false
    @State private var showDeleteConfirm = false
    @State private var selectedCardIDs = Set<PersistentIdentifier>()

    // Edit-selection mode for cards (Photos-like)
    @State private var isEditSelecting = false
    @State private var currentlySelectedCard: CardItem? = nil
    @State private var showEditSheet = false

    // Add flow: directly present AddCardView for the hidden Default section
    @State private var showAddCardSheet = false
    @State private var defaultSection: SectionItem? = nil

    // Settings: change level confirmation + navigation
    @State private var showChangeLevelAlert = false
    @State private var navigateToTargetUsers = false

    // Audio playback for cards
    private let audioService = AudioRecorderService()

    // Grid layout for cards
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 180), spacing: 16)
    ]

    // Fixed tint (since UCSView is not tied to a section)
    private var tint: Color { .lightBlue }

    // Reordered cards when isPressed (favorites first)
    private var displayedCards: [CardItem] {
        guard isPressed else { return cards }
        return cards.sorted { lhs, rhs in
            if lhs.isFavorite == rhs.isFavorite { return false }
            return lhs.isFavorite && !rhs.isFavorite
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .top) {
                Color.background
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    // Hidden navigation trigger to TargetUsers after confirmation
                    NavigationLink("", isActive: $navigateToTargetUsers) { TargetUsers() }
                        .hidden()

                    // Hero header: colored circle with a neutral icon
                    headerIcon

                    if displayedCards.isEmpty {
                        VStack(spacing: 10) {
                            Image(systemName: "square.stack.3d.up")
                                .font(.system(size: 36, weight: .regular))
                                .foregroundColor(.secondary)
                            Text("No cards yet")
                                .font(.custom("Rubik-Medium", size: 18))
                                .foregroundColor(.secondary)
                            Text("Tap + to add your first card.")
                                .font(.custom("Rubik-Regular", size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                    } else {
                        ScrollView {
                            LazyVGrid(columns: columns, spacing: 24) {
                                ForEach(displayedCards) { card in
                                    let isSelectedForDelete = selectedCardIDs.contains(card.persistentModelID)
                                    let isSelectedForEdit = currentlySelectedCard?.persistentModelID == card.persistentModelID && isEditSelecting

                                    cardCell(
                                        card,
                                        isInDeleteSelection: isSelecting,
                                        isSelectedForDelete: isSelectedForDelete,
                                        isInEditSelection: isEditSelecting,
                                        isSelectedForEdit: isSelectedForEdit
                                    )
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        if isSelecting {
                                            toggleDeleteSelection(card)
                                        } else if isEditSelecting {
                                            currentlySelectedCard = card
                                            showEditSheet = true
                                        } else {
                                            // Normal mode: play audio if available
                                            guard let data = card.audioData else { return }
                                            audioService.stopPlayback()
                                            audioService.loadExistingRecording(data: data)

                                            // Try first playback mode (.playback + .mixWithOthers)
                                            audioService.playbackMode = .playbackMix
                                            do {
                                                try audioService.startPlayback {
                                                    // finished
                                                }
                                            } catch {
                                                print("Playback with .playbackMix failed: \(error)")
                                                // Fallback: .playAndRecord + .defaultToSpeaker
                                                audioService.playbackMode = .playAndRecordSpeaker
                                                do {
                                                    try audioService.startPlayback {
                                                        // finished
                                                    }
                                                } catch {
                                                    print("Playback with .playAndRecordSpeaker failed: \(error)")
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.top, 24)
                            .padding(.horizontal, 36)
                            .padding(.bottom, 12)
                        }
                    }

                    Spacer()
                }
            }
            .toolbar {
                if isEditSelecting {
                    // Edit-selection toolbar like Photos: Cancel on the left, Done on the right
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            isEditSelecting = false
                            currentlySelectedCard = nil
                        }
                        .font(.custom("Rubik-Medium", size: 20))
                        .foregroundColor(.darkBlue)
                        .disabled(lock.isLocked)
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button("Done") {
                            isEditSelecting = false
                            currentlySelectedCard = nil
                        }
                        .font(.custom("Rubik-Medium", size: 20))
                        .foregroundColor(.darkBlue)
                        .disabled(lock.isLocked)
                    }
                } else if isSelecting {
                    // Delete-selection mode for cards
                    ToolbarItem(placement: .topBarLeading) {
                        Button("Cancel") {
                            exitDeleteSelectionMode()
                        }
                        .font(.custom("Rubik-Medium", size: 20))
                        .foregroundColor(.darkBlue)
                        .disabled(lock.isLocked)
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showDeleteConfirm = true
                        } label: {
                            Image(systemName: "trash")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(selectedCardIDs.isEmpty ? .secondary : .red)
                        }
                        .disabled(lock.isLocked || selectedCardIDs.isEmpty)
                    }
                } else {
                    // Normal toolbar mirroring SectionDetailView
                    ToolbarItem(id: "Lock", placement: .topBarTrailing) {
                        Button {
                            // Toggle the shared lock (toolbar-only lock)
                            lock.isLocked.toggle()
                            if lock.isLocked {
                                audioService.stopPlayback()
                                exitDeleteSelectionMode()
                                isEditSelecting = false
                                currentlySelectedCard = nil
                            }
                        } label: {
                            Image(systemName: lock.isLocked ? "lock" : "lock.open")
                                .font(.custom("Rubik-Medium", size: 20))
                                .foregroundColor(.darkBlue)
                        }
                    }

                    ToolbarItem(id: "Star", placement: .topBarTrailing) {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isPressed.toggle()
                            }
                        } label: {
                            Image(systemName: isPressed ? "star.fill" : "star")
                                .foregroundColor(isPressed ? .orange : .darkBlue)
                                .font(.custom("Rubik-Medium", size: 20))
                        }
                        .disabled(lock.isLocked)
                    }

                    ToolbarItem(id: "Settings", placement: .topBarTrailing) {
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
                        .disabled(lock.isLocked)
                    }
                    ToolbarItem(id: "Add", placement: .topBarTrailing) {
                        Button {
                            // Always get the single persistent Default section, then present immediately
                            do {
                                defaultSection = try SectionItem.fetchOrCreateDefault(in: modelContext)
                                showAddCardSheet = true
                            } catch {
                                print("Failed to get Default section: \(error)")
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.custom("Rubik-Medium", size: 20))
                                .foregroundColor(.darkBlue)
                        }
                        .disabled(lock.isLocked || defaultSection == nil)
                    }

                    ToolbarSpacer(.fixed, placement: .topBarTrailing)
                    
                    ToolbarItem(id: "Edit", placement: .topBarTrailing) {
                        Button {
                            // Enter edit-selection mode
                            isEditSelecting = true
                            currentlySelectedCard = nil
                        } label: {
                            Text("Edit")
                                .font(.custom("Rubik-Medium", size: 20))
                                .foregroundColor(.darkBlue)
                        }
                        .disabled(lock.isLocked || displayedCards.isEmpty)
                    }
                    
                    ToolbarSpacer(.fixed, placement: .topBarTrailing)

                    // Select for delete like Photos
                    ToolbarItem(id: "Select", placement: .topBarTrailing) {
                        Button {
                            isSelecting = true
                            isEditSelecting = false
                            selectedCardIDs.removeAll()
                            currentlySelectedCard = nil
                        } label: {
                            Text("Select")
                                .font(.custom("Rubik-Medium", size: 20))
                                .foregroundColor(.darkBlue)
                        }
                        .disabled(lock.isLocked || displayedCards.isEmpty)
                    }
                }
            }
            .confirmationDialog(
                "Delete Permanently?",
                isPresented: $showDeleteConfirm,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    performDeleteSelectedCards()
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
            // Edit sheet
            .sheet(isPresented: $showEditSheet) {
                if let card = currentlySelectedCard {
                    // Pass a placeholder hex for whitiesh; change this to match your asset if needed.
                    EditCardView(card: card, sectionTintHex: "#BFEAF2")
                } else {
                    Text("No card selected")
                        .font(.custom("Rubik-Medium", size: 18))
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
            // Add flow: present AddCardView for the hidden Default section
            .sheet(isPresented: $showAddCardSheet) {
                if let section = defaultSection {
                    AddCardView(section: section)
                } else {
                    VStack(spacing: 12) {
                        ProgressView()
                        Text("Preparing…")
                            .font(.custom("Rubik-Medium", size: 16))
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            .onAppear {
                // Ensure Default exists up front; retry once on next runloop if needed to avoid any race
                do {
                    defaultSection = try SectionItem.fetchOrCreateDefault(in: modelContext)
                } catch {
                    DispatchQueue.main.async {
                        do {
                            self.defaultSection = try SectionItem.fetchOrCreateDefault(in: modelContext)
                        } catch {
                            print("Failed to ensure Default section onAppear: \(error)")
                        }
                    }
                }
            }
            .onDisappear {
                // Ensure playback stops when leaving this screen
                audioService.stopPlayback()
            }
            .navigationBarBackButtonHidden(true)
        }
    }

    // MARK: - Header icon (colored circle + neutral SF Symbol)
    private var headerIcon: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(tint)
                    .frame(width: 120, height: 120)
                    .glassEffect(.regular.interactive())

                Image(systemName: "square.stack.3d.up")
                    .font(.system(size: 48, weight: .semibold))
                    .foregroundStyle(.black.opacity(0.3))
            }
        }
        .padding(.top, 6)
    }

    // MARK: - Card cell
    @ViewBuilder
    private func cardCell(
        _ card: CardItem,
        isInDeleteSelection: Bool,
        isSelectedForDelete: Bool,
        isInEditSelection: Bool,
        isSelectedForEdit: Bool
    ) -> some View {

        ZStack {
            // Card background (fixed size)
            RoundedRectangle(cornerRadius: 17)
                .fill(tint.opacity(0.9))
                .frame(width: 200, height: 200)
                .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 17))

            // Content inside the card
            VStack(spacing: 8) {
                // Image area (fixed 180x180, centered)
                if let data = card.imageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 180, height: 150) // leave room for name within 200x200
                        .clipped()
                        .cornerRadius(12)
                } else {
                    Image(systemName: "photo")
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(.primary.opacity(0.7))
                        .frame(width: 180, height: 150)
                        .cornerRadius(12)

                }

                // Name inside the card
                Text(card.name)
                    .font(.custom("Rubik-Medium", size: 14))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                    .frame(width: 180)
            }
            .frame(width: 180, height: 180, alignment: .center)
        }
        // Favorite star overlay anchored inside the card
        .overlay(alignment: .topTrailing) {
            Button {
                card.isFavorite.toggle()
                try? modelContext.save()
            } label: {
                Image(systemName: card.isFavorite ? "star.fill" : "star")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(card.isFavorite ? .orange : .darkBlue.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 60, style: .continuous)
                            .fill(tint.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 60, style: .continuous)
                                    .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
                            )
                            .shadow(color: .black.opacity(0.06), radius: 2, x: 0, y: 1)
                    )
            }
            .buttonStyle(.plain)
            .padding(8) // keeps it inside the 200x200 card
        }
        // Selection highlight
        .overlay(
            Group {
                if isInDeleteSelection && isSelectedForDelete {
                    RoundedRectangle(cornerRadius: 19)
                        .stroke(Color.lightBlue.opacity(0.9), lineWidth: 3)
                        .padding(.horizontal, -4)
                        .padding(.vertical, -4)
                } else if isInEditSelection && isSelectedForEdit {
                    RoundedRectangle(cornerRadius: 19)
                        .stroke(Color.lightBlue.opacity(0.9), lineWidth: 3)
                        .padding(.horizontal, -4)
                        .padding(.vertical, -4)
                }
            }
        )
        .padding(10)
    }

    // MARK: - Delete helpers
    private func toggleDeleteSelection(_ card: CardItem) {
        let id = card.persistentModelID
        if selectedCardIDs.contains(id) {
            selectedCardIDs.remove(id)
        } else {
            selectedCardIDs.insert(id)
        }
    }

    private func exitDeleteSelectionMode() {
        isSelecting = false
        selectedCardIDs.removeAll()
    }

    private func performDeleteSelectedCards() {
        guard !selectedCardIDs.isEmpty else { return }
        let toDelete = cards.filter { selectedCardIDs.contains($0.persistentModelID) }
        toDelete.forEach { modelContext.delete($0) }
        try? modelContext.save()
    }

    // MARK: - Change Level (delete all data and navigate)
    private func deleteAllDataAndNavigate() {
        do {
            // Delete all cards
            let allCardsDescriptor = FetchDescriptor<CardItem>()
            let allCards = try modelContext.fetch(allCardsDescriptor)
            allCards.forEach { modelContext.delete($0) }

            // Delete all sections
            let allSectionsDescriptor = FetchDescriptor<SectionItem>()
            let allSections = try modelContext.fetch(allSectionsDescriptor)
            allSections.forEach { modelContext.delete($0) }

            try modelContext.save()
        } catch {
            print("Failed to delete all data: \(error)")
        }
        navigateToTargetUsers = true
    }
}

#Preview {
    return UCSView()
//        .environmentObject(LockState())
}
