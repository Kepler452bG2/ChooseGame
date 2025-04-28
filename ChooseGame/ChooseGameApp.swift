//
//  ChooseGameApp.swift
//  ChooseGame
//
//  Created by Shepard on 28.04.2025.
//

import SwiftUI

@main
struct ChooseGameApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}



