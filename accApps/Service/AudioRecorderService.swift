import AVFoundation

final class AudioRecorderService: NSObject, AVAudioPlayerDelegate {

    enum PlaybackMode {
        case playbackMix            // AVAudioSession.Category.playback + .mixWithOthers
        case playAndRecordSpeaker   // AVAudioSession.Category.playAndRecord + .defaultToSpeaker
    }

    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?

    // آخر ملف تسجيل
    private(set) var currentFileURL: URL?

    private var playbackCompletion: (() -> Void)?

    // Choose which playback mode to use. Start with `.playbackMix`, switch to `.playAndRecordSpeaker` if needed.
    var playbackMode: PlaybackMode = .playbackMix

    // طلب إذن الميكروفون
    func requestPermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    // بدء التسجيل
    func startRecording() throws {
        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playAndRecord,
                                mode: .default,
                                options: [.defaultToSpeaker])
        try session.setActive(true)

        let filename = UUID().uuidString + ".m4a"
        let url = FileManager.default
            .temporaryDirectory
            .appendingPathComponent(filename)

        currentFileURL = url

        let settings: [String: Any] = [
            AVFormatIDKey: kAudioFormatMPEG4AAC,
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        recorder = try AVAudioRecorder(url: url, settings: settings)
        recorder?.record()
    }

    // إيقاف التسجيل
    func stopRecording() {
        recorder?.stop()
        recorder = nil
    }

    // تشغيل التسجيل
    func startPlayback(completion: @escaping () -> Void) throws {
        guard let url = currentFileURL else {
            print("❌ No file URL to play")
            return
        }

        // Diagnostics: file size
        let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? NSNumber)?.intValue ?? -1
        print("▶️ Attempting playback: \(url.lastPathComponent), size=\(fileSize) bytes")

        // Configure session based on selected mode
        let session = AVAudioSession.sharedInstance()
        switch playbackMode {
        case .playbackMix:
            try session.setCategory(.playback,
                                    mode: .default,
                                    options: [.mixWithOthers])
        case .playAndRecordSpeaker:
            try session.setCategory(.playAndRecord,
                                    mode: .default,
                                    options: [.defaultToSpeaker])
        }
        try session.setActive(true)

        // Force speaker when using playAndRecordSpeaker (helps on iPad)
        if playbackMode == .playAndRecordSpeaker {
            do {
                try session.overrideOutputAudioPort(.speaker)
            } catch {
                // Non-fatal; continue without override
                print("⚠️ overrideOutputAudioPort(.speaker) failed: \(error)")
            }
        }

        // Diagnostics: current route
        let route = session.currentRoute
        let inputs = route.inputs.map { $0.portType.rawValue }.joined(separator: ",")
        let outputs = route.outputs.map { $0.portType.rawValue }.joined(separator: ",")
        print("🔊 AVAudioSession route -> inputs: [\(inputs)] outputs: [\(outputs)]")

        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.delegate = self
            player?.prepareToPlay()
            playbackCompletion = completion
            let ok = player?.play() ?? false
            print(ok ? "✅ Playback started" : "⚠️ AVAudioPlayer.play() returned false")
        } catch {
            print("❌ AVAudioPlayer init error: \(error)")
            throw error
        }
    }

    func stopPlayback() {
        player?.stop()
        player = nil
        playbackCompletion = nil
    }

    func deleteRecording() {
        stopRecording()
        stopPlayback()
        if let url = currentFileURL {
            try? FileManager.default.removeItem(at: url)
        }
        currentFileURL = nil
    }

    // Load an existing recording from a file URL (keeps encapsulation)
    func loadExistingRecording(from url: URL) {
        // Stop anything in progress
        stopRecording()
        stopPlayback()
        // Replace current file URL with provided one (do not delete provided URL)
        currentFileURL = url
    }

    // Convenience: load from raw Data by writing to a temp file
    func loadExistingRecording(data: Data) {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".m4a")
        do {
            try data.write(to: url, options: .atomic)
            loadExistingRecording(from: url)
        } catch {
            print("Failed to write audio data to temp file: \(error)")
        }
    }

    // MARK: - AVAudioPlayerDelegate
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        let completion = playbackCompletion
        playbackCompletion = nil
        DispatchQueue.main.async {
            completion?()
        }
    }
}
