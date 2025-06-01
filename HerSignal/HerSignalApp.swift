//
//  HerSignalApp.swift
//  HerSignal
//
//  Created by Omar Choudhry on 01/06/2025.
//

import SwiftUI

@main
struct HerSignalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
