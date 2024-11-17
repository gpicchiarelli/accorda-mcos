//
//  accorda_mcosApp.swift
//  accorda-mcos
//
//  Created by GIACOMO PICCHIARELLI on 17/11/24.
//

import SwiftUI

@main
struct accorda_mcosApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
