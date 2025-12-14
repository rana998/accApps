import SwiftUI
import SwiftData

struct CombinedSentenceView: View {
    let words: [String]
    var onClose: () -> Void

    @Environment(\.modelContext) private var modelContext

    @State private var isPlayingQueue = false
    @State private var currentIndex: Int = 0

    // We’ll hold the prepared audio clips as Data in order of the words array.
    @State private var audioQueue: [Data] = []

    // Use your existing audio service (AVAudioPlayer-based).
    private let audioService = AudioRecorderService()

    // Choose a soft tint similar to AddCardView’s sectionTint fallback
    private var sheetTint: Color { .lightBlue }

    private var sentence: String {
        let raw = words.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return "" }
        let capped = raw.prefix(1).uppercased() + raw.dropFirst()
        if capped.last.map({ ".!?".contains($0) }) == true {
            return String(capped)
        } else {
            return capped + "."
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Tinted background like AddCardView
                sheetTint.opacity(0.5)
                    .ignoresSafeArea()

                // Centered rounded container (mirrors AddCardView proportions/feel)
                VStack(spacing: 20) {
                    Text("Combined Sentence")
                        .font(.custom("Rubik-SemiBold", size: 22))
                        .foregroundColor(.darkBlue)

                    // Big rounded display for the sentence (analogous to the image square)
                    ZStack {
                        RoundedRectangle(cornerRadius: 17)
                            .fill(sheetTint.opacity(0.15))
                            .frame(width: 520, height: 160)

                        Text(sentence.isEmpty ? "No words yet" : sentence)
                            .font(.custom("Rubik-SemiBold", size: 28))
                            .foregroundColor(.darkBlue)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .frame(width: 520, height: 160, alignment: .center)
                    }
                    .padding(.top, 6)

                    // Divider similar to AddCardView’s divider
                    Rectangle()
                        .fill(Color.primary.opacity(0.08))
                        .frame(width: 400, height: 1)
                        .padding(.horizontal, 10)
                        .padding(.top, 6)

                    // Action row (copy + speak) with circular controls to match style
                    HStack(spacing: 20) {
                        // Copy
                        Button {
                            UIPasteboard.general.string = sentence
                        } label: {
                            circleControl(
                                icon: "doc.on.doc",
                                fg: .darkBlue,
                                bg: Color.white.opacity(0.85),
                                size: 56
                            )
                        }
                        .overlay(
                            Circle().stroke(sheetTint.opacity(0.25), lineWidth: 2.5)
                        )
                        .glassEffect(.regular.interactive())
                        .disabled(sentence.isEmpty)

                        // Play queue / Stop
                        Button {
                            handleSpeakTapped()
                        } label: {
                            circleControl(
                                icon: isPlayingQueue ? "stop.fill" : "speaker.wave.2.fill",
                                fg: .darkBlue,
                                bg: Color.white.opacity(0.18),
                                size: 56
                            )
                        }
                        .overlay(
                            Circle().stroke(sheetTint.opacity(0.25), lineWidth: 2.5)
                        )
                        .glassEffect(.regular.interactive())
                        .disabled(words.isEmpty)
                    }

                    // Fixed-height status area (keeps sheet height stable)
                    ZStack {
                        Color.clear.frame(height: 22)
                        if isPlayingQueue {
                            HStack(spacing: 6) {
                                Image(systemName: "waveform.circle.fill")
                                    .foregroundColor(sheetTint)
                                Text("Playing your recordings…")
                                    .font(.custom("Rubik-Medium", size: 14))
                                    .foregroundColor(.secondary)
                            }
                            .transition(.opacity)
                        }
                    }

                    // Bottom buttons (match AddCardView sizing/feel)
                    VStack(spacing: 12) {
                        Button {
                            stopPlayback()
                            onClose()
                        } label: {
                            Text("Back")
                                .font(.custom("Rubik-Medium", size: 18))
                                .foregroundColor(.primary)
                                .frame(width: 230, height: 20)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 30)
                                        .fill(Color.primary.opacity(0.12))
                                )
                        }
                        .padding(.horizontal, 28)
                        .padding(.bottom, 6)
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
        }
        .onDisappear { stopPlayback() }
    }

    // MARK: - Controls building blocks (mirrors AddCardView)
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

    // MARK: - Playback actions

    private func handleSpeakTapped() {
        if isPlayingQueue {
            // Stop everything
            stopPlayback()
        } else {
            // Build the queue from the words and start playing
            prepareQueueAndPlay()
        }
    }

    private func prepareQueueAndPlay() {
        // Reset previous state
        audioService.stopPlayback()
        audioQueue.removeAll()
        currentIndex = 0

        // Build queue: for each word, look up a CardItem by name (case-insensitive), newest first
        for raw in words {
            let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            // Fetch cards matching this name (case-insensitive)
            // Since SwiftData predicates for case-insensitive contains are limited,
            // we’ll fetch a small set and filter in-memory.
            let descriptor = FetchDescriptor<CardItem>()
            if let matches = try? modelContext.fetch(descriptor) {
                // Filter by case-insensitive equality, prefer newest
                let candidates = matches
                    .filter { $0.name.trimmingCharacters(in: .whitespacesAndNewlines).localizedCaseInsensitiveCompare(trimmed) == .orderedSame }
                    .sorted { $0.createdAt > $1.createdAt }

                if let data = candidates.first?.audioData {
                    audioQueue.append(data)
                } else {
                    // No audio for this word — skip
                }
            }
        }

        guard !audioQueue.isEmpty else {
            // Nothing to play
            isPlayingQueue = false
            return
        }

        isPlayingQueue = true
        playCurrentIndex()
    }

    private func playCurrentIndex() {
        guard isPlayingQueue, currentIndex < audioQueue.count else {
            // Finished or stopped
            isPlayingQueue = false
            return
        }

        let clip = audioQueue[currentIndex]
        audioService.stopPlayback()
        audioService.loadExistingRecording(data: clip)
        do {
            try audioService.startPlayback {
                // When this clip finishes, advance to the next and play
                currentIndex += 1
                playCurrentIndex()
            }
        } catch {
            // On failure, skip to next
            currentIndex += 1
            playCurrentIndex()
        }
    }

    private func stopPlayback() {
        isPlayingQueue = false
        audioService.stopPlayback()
        currentIndex = 0
    }
}
