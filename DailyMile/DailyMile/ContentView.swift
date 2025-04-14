//
//  ContentView.swift
//  DailyMile
//
//  Created by Lucas Ho on 4/13/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        MainTabView()
    }
}

#Preview {
    ContentView()
        .environmentObject(AppState(demoMode: true))
}
