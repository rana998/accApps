import SwiftUI
import SwiftData
import Combine

struct AddSectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @StateObject private var vm = AddSectionViewModel()

    // UI state
    @State private var showCustomColorPicker = false
    @State private var showIconPicker = false
    @State private var iconSearchText: String = ""
    @FocusState private var isNameFocused: Bool
    @FocusState private var isIconTextFocused: Bool

    var body: some View {
        NavigationStack {
            ZStack {
                
                Color.lightBlue.opacity(0.5)
                    .ignoresSafeArea()
                // Centered card
                VStack(spacing: 20) {
                    Text("Add New Section")
                        .font(.custom("Rubik-SemiBold", size: 22))
                        .foregroundColor(.darkBlue)

                    // Big circular preview with icon
                    ZStack {
                        Circle()
                            .fill(vm.selectedColor)
                            .frame(width: 200, height: 200)
                            .glassEffect(.regular.interactive())

                        Image(systemName: vm.effectiveIconName.isEmpty ? "questionmark" : vm.effectiveIconName)
                            .font(.system(size: 100, weight: .semibold))
                            .foregroundStyle(.black.opacity(0.3))
                    }
                    .padding(.top, 6)

                    // Color row + color picker inline
                    HStack(spacing: 12) {
                        ForEach(Array(vm.suggestedColors.prefix(6).enumerated()), id: \.offset) { _, color in
                            Button {
                                vm.selectedColor = color
                            } label: {
                                Circle()
                                    .fill(color)
                                    .frame(width: 38, height: 38)
                                    .overlay(
                                        Circle()
                                            .stroke(Color.primary.opacity(vm.selectedColor == color ? 0.5 : 0), lineWidth: 2)
                                    )
                            }
                            .glassEffect(.clear.interactive())
                        }

                        // Inline ColorPicker
                        ColorPicker("", selection: $vm.selectedColor, supportsOpacity: false)
                            .labelsHidden()
                            .frame(width: 38, height: 38)
                            .glassEffect(.clear.interactive())
                    }
                    .padding(.horizontal, 18)

                    // Icon row + custom button
                    HStack(spacing: 12) {
                        ForEach(vm.suggestedIcons.prefix(6), id: \.self) { icon in
                            Button {
                                vm.selectedIcon = icon
                                vm.customIconName = ""
                                isIconTextFocused = false
                            } label: {
                                Image(systemName: icon)
                                    .font(.system(size: 22, weight: .regular))
                                    .foregroundColor(.primary)
                                    .frame(width: 38, height: 38)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color.clear)
                                    )
                            }
                            .buttonStyle(.plain)
                        }

                        // Plus button that opens "all icons" picker (same size/feel as ColorPicker)
                        Button {
                            iconSearchText = ""
                            showIconPicker = true
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.clear)
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary.opacity(0.7))
                            }
                            .frame(width: 38, height: 38)
                        }
                        .buttonStyle(.plain)
                        .glassEffect(.clear.interactive())
                    }
                    .padding(.horizontal, 18)

                    // Divider like in the mock
                    Rectangle()
                        .fill(Color.primary.opacity(0.08))
                        .frame(height: 1)
                        .padding(.horizontal, 18)
                        .padding(.top, 6)

                    // Name field + hidden icon field (appears when focused)
                    VStack(alignment: .leading, spacing: 12) {
                        // Custom SF Symbol name field (lightweight, only when focused or text not empty)
                        if isIconTextFocused || !vm.customIconName.isEmpty {
                            TextField("SF Symbol name (e.g. star.fill)", text: $vm.customIconName)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled(true)
                                .font(.system(.body, design: .monospaced))
                                .padding(.horizontal, 16)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.primary.opacity(0.05))
                                )
                                .focused($isIconTextFocused)
                                .padding(.horizontal, 28)
                        }

                        // Section name field
                        TextField("Section name", text: $vm.name)
                            .textInputAutocapitalization(.words)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.clear.opacity(0.05))
                            )
                            .focused($isNameFocused)
                            .padding(.horizontal, 28)
                    }
//                    .padding(.top, 4)

                    // Buttons
                    VStack(spacing: 12) {
                        Button(action: save) {
                            Text("Save Section")
                                .font(.custom("Rubik-Medium", size: 18))
                                .foregroundColor(.primary)
                                .frame(width: 230, height: 20)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color.lightBlue.opacity(vm.canSave ? 1.0 : 0.4))
                                )
                                .glassEffect(.regular.interactive())
                        }
                        .disabled(!vm.canSave)
                        .padding(.horizontal, 28)

                        Button {
                            dismiss()
                        } label: {
                            Text("Cancel")
                                .font(.custom("Rubik-Medium", size: 18))
                                .foregroundColor(.primary.opacity(0.8))
                                .frame(width: 230, height: 20)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color.primary.opacity(0.12))
                                )
                        }
                        .padding(.horizontal, 28)
                        .padding(.bottom, 16)
                    }
                }
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 28)
                        .fill(Color.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 24)
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showIconPicker) {
                IconPickerSheet(
                    allIcons: vm.suggestedIcons, // swap in a larger list later
                    selected: vm.selectedIcon,
                    searchText: $iconSearchText
                ) { picked in
                    vm.selectedIcon = picked
                    vm.customIconName = ""
                    isIconTextFocused = false
                    showIconPicker = false
                }
            }
        }
    }

    private func save() {
        guard let hex = vm.selectedColor.toHex() else { return }
        let item = SectionItem(
            name: vm.name.trimmingCharacters(in: .whitespacesAndNewlines),
            colorHex: hex,
            iconName: vm.effectiveIconName
        )
        modelContext.insert(item)
        dismiss()
    }
}

// A lightweight sheet that shows a searchable grid of icons
private struct IconPickerSheet: View {
    let allIcons: [String]
    let selected: String
    @Binding var searchText: String
    var onPick: (String) -> Void

    private var filteredIcons: [String] {
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return allIcons }
        return allIcons.filter { $0.localizedCaseInsensitiveContains(trimmed) }
    }

    // 6 columns for a dense grid
    private let columns: [GridItem] = Array(repeating: GridItem(.flexible(minimum: 44, maximum: 80), spacing: 12), count: 6)

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search SF Symbols", text: $searchText)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.primary.opacity(0.06))
                )
                .padding(.horizontal)

                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(filteredIcons, id: \.self) { icon in
                            Button {
                                onPick(icon)
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.primary.opacity(icon == selected ? 0.12 : 0.06))
                                    Image(systemName: icon)
                                        .font(.system(size: 20, weight: .regular))
                                        .foregroundColor(.primary)
                                }
                                .frame(height: 44)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .padding(.vertical)
            .navigationTitle("Choose Icon")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

