//
//  AR_BookApp.swift
//  AR_Book
//
//  Created by Gurpreet on 22/07/25.
//

import SwiftUI
import FirebaseCore

@main
struct AR_BookApp: App {
    
    init() {
            FirebaseApp.configure()
        }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
