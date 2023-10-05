//
//  DebateApp.swift
//  Debate
//
//  Created by Terrell Davis on 3/22/23.
//

import SwiftUI
import Firebase

@main
struct DebateApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(User())
        }
    }
}
