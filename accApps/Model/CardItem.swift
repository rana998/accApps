// CardItem.swift
import Foundation
import SwiftData

@Model
final class CardItem {
    var name: String
    var imageData: Data?
    var audioData: Data?
    var createdAt: Date
    var isFavorite: Bool

    init(
        name: String,
        imageData: Data? = nil,
        audioData: Data? = nil,
        createdAt: Date = .now,
        isFavorite: Bool = false
    ) {
        self.name = name
        self.imageData = imageData
        self.audioData = audioData
        self.createdAt = createdAt
        self.isFavorite = isFavorite
    }
}

