//
//  accAppsApp.swift
//  accApps
//
//  Created by Rana on 01/06/1447 AH.
//

import SwiftUI
import SwiftData
import Combine

// Moved here from LockState.swift to reduce file count.
final class LockState: ObservableObject {
    @Published var isLocked: Bool = false
}

@main
struct accAppsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
            SectionItem.self,
            CardItem.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @StateObject private var lockState = LockState()
    var body: some Scene {
        WindowGroup {
            StartScreen()
                .environmentObject(lockState) // Add this line
        }
        .modelContainer(sharedModelContainer)
    }
}
