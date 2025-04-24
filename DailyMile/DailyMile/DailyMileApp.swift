//
//  DailyMileApp.swift
//  DailyMile
//
//  Created by Lucas Ho, Kyle Tarczon, and Pierre Garcia, and Linh Ngo.
//

import SwiftUI

@main
struct DailyMileApp: App {
    @StateObject private var appState = AppState(demoMode: true)
    
    init() {
        // Initialize color scheme when app starts
        let tempAppState = AppState(demoMode: true)
        tempAppState.updateColorScheme()
        // Note: We can't directly access @StateObject here, but the actual instance
        // will update its scheme via the onChange modifier when it's created
    }
    
    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                MainTabView()
                    .environmentObject(appState)
                    .preferredColorScheme(appState.colorScheme)
                    .transition(.opacity)
                    .onAppear {
                        // Ensure color scheme is set when view appears
                        appState.updateColorScheme()
                    }
            } else {
                LoginView()
                    .environmentObject(appState)
                    .preferredColorScheme(appState.colorScheme)
                    .transition(.opacity)
                    .onAppear {
                        // Ensure color scheme is set when view appears
                        appState.updateColorScheme()
                    }
            }
        }
        .onChange(of: appState.themeMode) { _ in
            appState.updateColorScheme()
        }
    }
}
