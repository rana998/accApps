//
//  ViewModel.swift
//  accApps
//
//  Created by Jana Abdulaziz Malibari on 02/12/2025.
//

import SwiftUI
internal import Combine

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
