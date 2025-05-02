//
//  BidCastApp.swift
//  BidCast
//
//  Created by Abdul-JAM-E-157 on 02/05/25.
//

import SwiftUI

@main
struct BidCastApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
