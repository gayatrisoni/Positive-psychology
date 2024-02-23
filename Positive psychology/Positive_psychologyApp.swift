//
//  Positive_psychologyApp.swift
//  Positive psychology
//
//  Created by Gayatri Soni on 2/23/24.
//

import SwiftUI

@main
struct Positive_psychologyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
