//
//  accAppsApp.swift
//  accApps
//
//  Created by Rana on 01/06/1447 AH.
//

import SwiftUI
import SwiftData

@main
struct accAppsApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            StartScreen()
        }
        .modelContainer(sharedModelContainer)
    }
}
