//
//  CardData.swift
//  accApps
//
//  Created by Jana Abdulaziz Malibari on 12/12/2025.
//

import SwiftUI
import UIKit

struct CardData: Identifiable, Equatable {
    let id: UUID
    var title: String
    var image: UIImage?
    var audioURL: URL?

    init(
        id: UUID = UUID(),
        title: String,
        image: UIImage? = nil,
        audioURL: URL? = nil
    ) {
        self.id = id
        self.title = title
        self.image = image
        self.audioURL = audioURL
    }
}
struct RecordVoiceState {
    var cardName: String = ""
    var isRecording: Bool = false
    var isPlaying: Bool = false
    var hasRecording: Bool = false

    var selectedImage: UIImage? = nil

    // رابط ملف التسجيل الحالي
    var recordingURL: URL? = nil
}
enum RecordVoiceIntent {
    case updateName(String)
    case recordTapped
    case playTapped
    case deleteTapped
    case saveTapped
    case cancelTapped
    case imageSelected(UIImage)
}
