//
//  for_WBPartnersApp.swift
//  for_WBPartners
//
//  Created by Lilia Chechina on 12.06.2025.
//

import SwiftUI

@main
struct for_WBPartnersApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
