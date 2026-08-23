import Combine
import SwiftUI

struct ACSLibraryPickerSheet: View {
    @ObservedObject var viewModel: ACSLibraryPickerViewModel
    let onCancel: () -> Void
    let onAddSelected: () -> Void

    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.sections) { section in
                    Section {
                        if viewModel.isSectionExpanded(section) {
                            // Select All / Deselect All row
                            HStack {
                                Button("Select All") { viewModel.selectAllItems(in: section) }
                                Spacer()
                                Button("Deselect All") { viewModel.deselectAllItems(in: section) }
                            }
                            .font(.custom("Rubik-Medium", size: 14))

                            ForEach(section.items) { item in
                                HStack {
                                    Image(systemName: viewModel.isItemSelected(section: section, item: item) ? "checkmark.circle.fill" : "circle")
                                        .foregroundColor(viewModel.isItemSelected(section: section, item: item) ? .blue : .secondary)
                                    Text(item.name)
                                        .font(.custom("Rubik-Medium", size: 16))
                                    Spacer()
                                }
                                .contentShape(Rectangle())
                                .onTapGesture { viewModel.toggleItemSelection(section: section, item: item) }
                            }
                        }
                    } header: {
                        HStack {
                            Text(section.name)
                                .font(.custom("Rubik-Medium", size: 18))
                            Spacer()
                            Button(action: { viewModel.toggleSectionExpanded(section) }) {
                                Image(systemName: viewModel.isSectionExpanded(section) ? "chevron.down" : "chevron.right")
                                    .foregroundColor(.secondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .navigationTitle("Library")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { onCancel() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Selected") { onAddSelected() }
                        .disabled(!viewModel.canAdd)
                }
            }
            .onAppear { viewModel.load() }
        }
    }
}
