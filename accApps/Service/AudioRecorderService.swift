import AVFoundation

final class AudioRecorderService: NSObject, AVAudioPlayerDelegate {

    private var recorder: AVAudioRecorder?
    private var player: AVAudioPlayer?

    // آخر ملف تسجيل
    private(set) var currentFileURL: URL?

    private var playbackCompletion: (() -> Void)?

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
            print("❌ لا يوجد ملف صوت لتشغيله")
            return
        }

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(.playback,
                                mode: .default,
                                options: [.defaultToSpeaker])
        try session.setActive(true)

        player = try AVAudioPlayer(contentsOf: url)
        player?.delegate = self
        player?.prepareToPlay()
        playbackCompletion = completion
        player?.play()
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

