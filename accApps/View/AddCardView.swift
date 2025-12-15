// AddCardView.swift
import SwiftUI
import PhotosUI
import SwiftData
import AVFoundation

struct AddCardView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let section: SectionItem

    @State private var name: String = ""
    @State private var pickedImage: UIImage? = nil

    // Image picking
    @State private var photoItem: PhotosPickerItem? = nil
    @State private var showCamera = false
    @State private var showPhotoSourceMenu = false
    @State private var showPhotosPickerSheet = false

    // Audio
    @State private var isRecording = false
    @State private var isPlaying = false
    @State private var hasRecordedAudio = false
    private let audioService = AudioRecorderService()

    // Focus
    @FocusState private var isNameFocused: Bool

    // Derived tint from section color
    private var sectionTint: Color {
        Color(hex: section.colorHex) ?? .lightBlue
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.lightBlue.opacity(0.5)
                    .ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Add a New Card")
                        .font(.custom("Rubik-SemiBold", size: 22))
                        .foregroundColor(.darkBlue)

                    // Big square preview (tappable to choose source)
                    ZStack {
                        RoundedRectangle(cornerRadius: 17)
                            .fill(sectionTint.opacity(0.15))
                            .frame(width: 180, height: 180)

                        if let img = pickedImage {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 180, height: 180)
                                .clipped()
                                .cornerRadius(17)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 17)
                                        .stroke(sectionTint.opacity(0.35), lineWidth: 1)
                                )
                        } else {
                            VStack(spacing: 8) {
                                Image(systemName: "icloud.and.arrow.up")
                                    .font(.system(size: 36, weight: .regular))
                                    .foregroundColor(sectionTint.opacity(0.8))
                                Text("Upload / Take Photo")
                                    .font(.custom("Rubik-Medium", size: 16))
                                    .foregroundColor(.secondary)
                            }
                            .frame(width: 180, height: 180)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.7))
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(sectionTint.opacity(0.35), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.top, 6)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        showPhotoSourceMenu = true
                    }

                    // Divider like AddSectionView
                    Rectangle()
                        .fill(Color.primary.opacity(0.08))
                        .frame(width: 400, height: 1)
                        .padding(.horizontal, 10)
                        .padding(.top, 6)

                    // Name field (same style as section name field)
                    TextField("Card Name", text: $name)
                        .textInputAutocapitalization(.words)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.clear.opacity(0.05))
                        )
                        .focused($isNameFocused)
                        .padding(.horizontal, 38)

                    // Audio section
                    VStack(spacing: 12) {
                        Text("Please Record Your Voice")
                            .font(.custom("Rubik-Medium", size: 18))
                            .foregroundColor(.darkBlue)

                        HStack(spacing: 20) {
                            // Delete
                            Button(role: .destructive) {
                                audioService.deleteRecording()
                                hasRecordedAudio = false
                                isPlaying = false
                                isRecording = false
                            } label: {
                                circleControl(
                                    icon: "trash",
                                    fg: .darkBlue,
                                    bg: Color.white.opacity(0.85),
                                    size: 56
                                )
                            }
                            .overlay(
                                Circle().stroke(Color.red.opacity(0.25), lineWidth: 2.5)
                            )
                            .glassEffect(.regular.interactive())
                            .disabled(!hasRecordedAudio)

                            // Record / Stop
                            Button {
                                handleRecordTapped()
                            } label: {
                                circleControl(
                                    icon: isRecording ? "stop.fill" : "mic",
                                    fg: .darkBlue,
                                    bg: Color.white.opacity(0.25),
                                    size: 80
                                )
                            }
                            .overlay(
                                Circle().stroke(sectionTint.opacity(0.25), lineWidth: 2.5)
                            )
                            .glassEffect(.regular.interactive())

                            // Play / Stop
                            Button {
                                handlePlayTapped()
                            } label: {
                                circleControl(
                                    icon: isPlaying ? "stop.fill" : "play.fill",
                                    fg: .darkBlue,
                                    bg: Color.white.opacity(0.18),
                                    size: 56
                                )
                                
                            }
                            .overlay(
                                Circle().stroke(sectionTint.opacity(0.25), lineWidth: 2.5)
                            )
                            .glassEffect(.regular.interactive())
                            .disabled(!hasRecordedAudio)
                        }

                        // Fixed-height status area (prevents sheet height changes)
                        ZStack {
                            Color.clear.frame(height: 22)
                            if hasRecordedAudio {
                                HStack(spacing: 4) {
                                    Image(systemName: "waveform.circle.fill")
                                        .foregroundColor(sectionTint)
                                    Text("Recording saved")
                                        .font(.custom("Rubik-Medium", size: 14))
                                        .foregroundColor(.secondary)
                                }
                                .transition(.opacity)
                            }
                        }
                    }

                    // Buttons
                    VStack(spacing: 12) {
                        Button(action: save) {
                            Text("Save Card")
                                .font(.custom("Rubik-Medium", size: 18))
                                .foregroundColor(.primary)
                                .frame(width: 230, height: 20)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(sectionTint.opacity(canSave ? 1.0 : 0.4))
                                )
                                .glassEffect(.regular.interactive())
                        }
                        .disabled(!canSave)
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
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 24)
                        .fill(Color.white.opacity(0.9))
                        .shadow(color: .black.opacity(0.08), radius: 20, x: 0, y: 10)
                )
                .padding(.horizontal, 48)
            }
            .toolbar(.hidden, for: .navigationBar)

            // Camera sheet
            .sheet(isPresented: $showCamera) {
                CameraPicker(image: $pickedImage)
            }
            // Present the Photos picker UI immediately when requested
            .sheet(isPresented: $showPhotosPickerSheet) {
                PhotosPicker(selection: $photoItem, matching: .images) {
                    // Minimal visible label so the sheet renders and the system picker appears
                    HStack {
                        ProgressView().tint(.secondary)
                        Text("Loading Photos…")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
            }
            // Load the selected photo and dismiss the sheet
            .onChange(of: photoItem) { _, newValue in
                Task { await loadSelectedPhoto(newValue) }
            }

            // Photo source action sheet
            .confirmationDialog(
                "Choose how to add the image",
                isPresented: $showPhotoSourceMenu,
                titleVisibility: .visible
            ) {
                Button("Choose From Library") {
                    showPhotosPickerSheet = true
                }
                Button("Take a Photo") {
                    if UIImagePickerController.isSourceTypeAvailable(.camera) {
                        showCamera = true
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
            .onDisappear {
                audioService.stopPlayback()
                audioService.stopRecording()
            }
        }
    }

    // MARK: - Controls building blocks

    private func circleControl(icon: String, fg: Color, bg: Color, size: CGFloat) -> some View {
        ZStack {
            Circle()
                .fill(bg)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.35), lineWidth: 0.5)
                )
                .glassEffect(.regular.interactive())
            Image(systemName: icon)
                .font(.system(size: size == 64 ? 22 : 20, weight: .semibold))
                .foregroundColor(fg)
        }
        .frame(width: size, height: size)
        .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 1)
    }

    // MARK: - Actions

    private func save() {
        var imageData: Data? = nil
        if let uiImage = pickedImage {
            imageData = uiImage.jpegData(compressionQuality: 0.8)
        }

        var audioData: Data? = nil
        if let url = audioService.currentFileURL {
            audioData = try? Data(contentsOf: url)
        }

        let card = CardItem(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            imageData: imageData,
            audioData: audioData
        )

        section.cards.append(card)

        do {
            try modelContext.save()
        } catch {
            print("Failed to save card: \(error)")
        }

        dismiss()
    }

    private func handleRecordTapped() {
        if isRecording {
            audioService.stopRecording()
            isRecording = false
            hasRecordedAudio = (audioService.currentFileURL != nil)
        } else {
            audioService.requestPermission { granted in
                guard granted else { return }
                do {
                    try audioService.startRecording()
                    isRecording = true
                } catch {
                    print("Recording failed to start: \(error)")
                }
            }
        }
    }

    private func handlePlayTapped() {
        if isPlaying {
            audioService.stopPlayback()
            isPlaying = false
        } else {
            do {
                try audioService.startPlayback {
                    isPlaying = false
                }
                isPlaying = true
            } catch {
                print("Playback failed: \(error)")
            }
        }
    }

    @MainActor
    private func loadSelectedPhoto(_ item: PhotosPickerItem?) async {
        guard let item else { return }
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            pickedImage = image
        }
        // Dismiss the PhotosPicker sheet after selection
        showPhotosPickerSheet = false
    }
}

// MARK: - Camera Picker (UIKit)
private struct CameraPicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        init(parent: CameraPicker) { self.parent = parent }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}
