//
//  ViewModel.swift
//  accApps
//
//  Created by Jana Abdulaziz Malibari on 02/12/2025.
//

import SwiftUI
import Combine
import AVFAudio

enum CardType {
    case noun, name, verb
}

struct SelectedCard: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let type: CardType
}


class ViewModel: ObservableObject {
    
    @Published var selectedNouns: [String] = []
    @Published var selectedNames: [String] = []
    @Published var selectedVerbs: [String] = []
    
    @Published var selectedCards: [SelectedCard] = []
    @Published var generatedSentence: String = ""
    
    func addCard(_ title: String, type: CardType) {
        let card = SelectedCard(title: title, type: type)
        let randomIndex = Int.random(in: 0...selectedCards.count)
        selectedCards.insert(card, at: randomIndex)
    }
    
    func removeCard(_ card: SelectedCard) {
        selectedCards.removeAll { $0.id == card.id }
    }
    
    func generateSentence() {
        generatedSentence = selectedCards.map { $0.title }.joined(separator: " ")
    }
    
}
final class RecordVoiceViewModel: ObservableObject {
    @Published private(set) var state = RecordVoiceState()
    private let audioService = AudioRecorderService()
    
    // MARK: - Intent Handling
    func send(_ intent: RecordVoiceIntent) {
        switch intent {
        case .updateName(let newName):
            state.cardName = newName
            
        case .recordTapped:
            handleRecordTapped()
            
        case .playTapped:
            handlePlayTapped()
            
        case .deleteTapped:
            handleDeleteTapped()
            
        case .saveTapped:
            handleSaveTapped()
            
        case .cancelTapped:
            handleCancelTapped()
            
        case .imageSelected(let image):
            state.selectedImage = image
        }
    }
    
    // MARK: - Recording
    private func handleRecordTapped() {
        if state.isRecording {
            // إيقاف التسجيل
            audioService.stopRecording()
            state.isRecording  = false
            state.hasRecording = true
            state.recordingURL = audioService.currentFileURL   // 👈 هنا نخزن رابط الملف
            print("✅ تم حفظ التسجيل في:", state.recordingURL?.absoluteString ?? "nil")
        } else {
            audioService.requestPermission { [weak self] granted in
                guard let self = self else { return }
                
                if granted {
                    do {
                        try self.audioService.startRecording()
                        self.state.isRecording  = true
                        self.state.hasRecording = false
                        self.state.recordingURL = nil
                    } catch {
                        print("Error: Failed to start recording →", error)
                    }
                } else {
                    print("Microphone permission denied")
                }
            }
        }
    }
    
    // MARK: - Playback (من داخل شاشة الإضافة)
    private func handlePlayTapped() {
        guard state.hasRecording else { return }
        
        if state.isPlaying {
            audioService.stopPlayback()
            state.isPlaying = false
        } else {
            do {
                try audioService.startPlayback { [weak self] in
                    self?.state.isPlaying = false
                }
                state.isPlaying = true
            } catch {
                print("Error: Failed to play →", error)
            }
        }
    }
    
    // MARK: - Delete Recording
    private func handleDeleteTapped() {
        audioService.deleteRecording()
        state.isRecording   = false
        state.isPlaying     = false
        state.hasRecording  = false
        state.recordingURL  = nil
        state.selectedImage = nil
        state.cardName      = ""
    }
    
    // MARK: - Save Card (للطباعة فقط)
    private func handleSaveTapped() {
        print("🎉 Saved card:")
        print("Name:", state.cardName)
        print("Has recording:", state.hasRecording)
        print("Recording URL:", state.recordingURL?.absoluteString ?? "nil")
        print("Has image:", state.selectedImage != nil)
    }
    
    // MARK: - Cancel
    private func handleCancelTapped() {
        state = RecordVoiceState()
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    
    @Binding var image: UIImage?
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    let sourceType: UIImagePickerController.SourceType
    let onImagePicked: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        
        let parent: ImagePicker
        init(_ parent: ImagePicker) { self.parent = parent }
        
        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onImagePicked(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

final class CardsViewModel: ObservableObject {
    @Published var cards: [CardData] = [
        
    ]
    
    private var audioPlayer: AVAudioPlayer?
    
    func addCard(_ card: CardData) {
        cards.append(card)
    }
    
    func play(card: CardData) {
        guard let url = card.audioURL else {
            print("لا يوجد تسجيل لهذا الكرت")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("خطأ في تشغيل الصوت: \(error.localizedDescription)")
        }
    }
}

