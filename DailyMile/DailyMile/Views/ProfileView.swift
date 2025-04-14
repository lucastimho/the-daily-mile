import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var appState: AppState
    
    // Local state for editing
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var weight: String = ""
    @State private var height: String = ""
    @State private var experience: UserProfile.RunnerExperience = .beginner
    @State private var weeklyGoal: String = ""
    
    @State private var isEditMode = false
    @State private var showingAccessibilitySettings = false
    
    var body: some View {
        NavigationView {
            Form {
                // User Info Section
                Section(header: Text("User Information")) {
                    if isEditMode {
                        TextField("Name", text: $name)
                        
                        HStack {
                            TextField("Age", text: $age)
                                .keyboardType(.numberPad)
                            Text("years")
                                .foregroundColor(ColorTheme.textSecondary)
                        }
                        
                        HStack {
                            TextField("Weight", text: $weight)
                                .keyboardType(.decimalPad)
                            Text("kg")
                                .foregroundColor(ColorTheme.textSecondary)
                        }
                        
                        HStack {
                            TextField("Height", text: $height)
                                .keyboardType(.decimalPad)
                            Text("cm")
                                .foregroundColor(ColorTheme.textSecondary)
                        }
                        
                        Picker("Experience Level", selection: $experience) {
                            ForEach(UserProfile.RunnerExperience.allCases) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        
                        HStack {
                            TextField("Weekly Goal", text: $weeklyGoal)
                                .keyboardType(.numberPad)
                            Text("miles")
                                .foregroundColor(ColorTheme.textSecondary)
                        }
                    } else {
                        ProfileInfoRow(label: "Name", value: appState.currentUser.name)
                        ProfileInfoRow(label: "Age", value: "\(appState.currentUser.age) years")
                        ProfileInfoRow(label: "Weight", value: "\(appState.currentUser.weight) kg")
                        ProfileInfoRow(label: "Height", value: "\(appState.currentUser.height) cm")
                        ProfileInfoRow(label: "Experience", value: appState.currentUser.experience.rawValue)
                        ProfileInfoRow(label: "Weekly Goal", value: "\(appState.currentUser.weeklyGoal) miles")
                    }
                }
                
                // Appearance Settings
                Section(header: Text("Appearance")) {
                    Picker("Theme Mode", selection: $appState.themeMode) {
                        ForEach(ThemeMode.allCases) { mode in
                            Text(mode.rawValue).tag(mode)
                        }
                    }
                    .onChange(of: appState.themeMode) { _ in
                        appState.updateColorScheme()
                    }
                }
                
                // Accessibility Settings
                Section(header: Text("Accessibility")) {
                    NavigationLink(destination: AccessibilitySettingsView(), isActive: $showingAccessibilitySettings) {
                        Label("Accessibility Settings", systemImage: "accessibility")
                    }
                }
                
                // App Settings
                Section(header: Text("App Settings")) {
                    Toggle("Demo Mode", isOn: $appState.isDemoMode)
                        .onChange(of: appState.isDemoMode) { value in
                            // In a real app, this would toggle between real and simulated data
                        }
                    
                    Button(action: {
                        // This would show help content in a real app
                    }) {
                        Label("Help & Support", systemImage: "questionmark.circle")
                    }
                    
                    Button(action: {
                        // This would show about content in a real app
                    }) {
                        Label("About The Daily Mile", systemImage: "info.circle")
                    }
                }
                
                // Edit/Save Button
                Section {
                    if isEditMode {
                        Button("Save Changes") {
                            saveChanges()
                            isEditMode = false
                        }
                        .foregroundColor(ColorTheme.success)
                        
                        Button("Cancel") {
                            // Reset local state
                            resetLocalState()
                            isEditMode = false
                        }
                        .foregroundColor(ColorTheme.error)
                    } else {
                        Button("Edit Profile") {
                            // Set local state
                            resetLocalState()
                            isEditMode = true
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                resetLocalState()
            }
        }
    }
    
    private func resetLocalState() {
        name = appState.currentUser.name
        age = "\(appState.currentUser.age)"
        weight = "\(appState.currentUser.weight)"
        height = "\(appState.currentUser.height)"
        experience = appState.currentUser.experience
        weeklyGoal = "\(appState.currentUser.weeklyGoal)"
    }
    
    private func saveChanges() {
        // Update app state with edited values
        // In a real app, we would validate inputs and handle errors
        
        let ageValue = Int(age) ?? appState.currentUser.age
        let weightValue = Double(weight) ?? appState.currentUser.weight
        let heightValue = Double(height) ?? appState.currentUser.height
        let goalValue = Int(weeklyGoal) ?? appState.currentUser.weeklyGoal
        
        appState.currentUser = UserProfile(
            name: name,
            age: ageValue,
            weight: weightValue,
            height: heightValue,
            experience: experience,
            weeklyGoal: goalValue
        )
    }
}

struct ProfileInfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            Text(value)
                .foregroundColor(ColorTheme.textSecondary)
        }
    }
}

struct AccessibilitySettingsView: View {
    @State private var highContrastMode = false
    @State private var largeText = false
    @State private var voiceGuidance = false
    @State private var reducedMotion = false
    
    var body: some View {
        Form {
            Section(header: Text("Display")) {
                Toggle("High Contrast Mode", isOn: $highContrastMode)
                Toggle("Large Text", isOn: $largeText)
            }
            
            Section(header: Text("Audio")) {
                Toggle("Voice Guidance", isOn: $voiceGuidance)
                
                if voiceGuidance {
                    Picker("Voice Type", selection: .constant("Default")) {
                        Text("Default").tag("Default")
                        Text("Male Voice").tag("Male")
                        Text("Female Voice").tag("Female")
                    }
                    
                    Slider(value: .constant(0.8), in: 0...1, step: 0.1) {
                        Text("Voice Volume")
                    } minimumValueLabel: {
                        Image(systemName: "speaker.fill")
                    } maximumValueLabel: {
                        Image(systemName: "speaker.wave.3.fill")
                    }
                }
            }
            
            Section(header: Text("Motion")) {
                Toggle("Reduced Motion", isOn: $reducedMotion)
            }
            
            Section(footer: Text("These settings help make the app more accessible to users with different needs.")) {
                Button("Reset to Defaults") {
                    highContrastMode = false
                    largeText = false
                    voiceGuidance = false
                    reducedMotion = false
                }
                .foregroundColor(ColorTheme.error)
            }
        }
        .navigationTitle("Accessibility")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ProfileView()
        .environmentObject(AppState(demoMode: true))
} 