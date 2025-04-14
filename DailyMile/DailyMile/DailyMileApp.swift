//
//  DailyMileApp.swift
//  DailyMile
//
//  Created by Lucas Ho on 4/13/25.
//

import SwiftUI

@main
struct DailyMileApp: App {
    @StateObject private var appState = AppState(demoMode: true)
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
                .preferredColorScheme(appState.colorScheme)
                .onAppear {
                    // Initialize color scheme based on saved preference
                    appState.updateColorScheme()
                }
        }
    }
}
