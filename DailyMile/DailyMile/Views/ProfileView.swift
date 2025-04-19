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
    @State private var showingLogoutConfirmation = false
    
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
                            Text(appState.unitPreference == .metric ? "kg" : "lbs")
                                .foregroundColor(ColorTheme.textSecondary)
                        }
                        
                        HStack {
                            TextField("Height", text: $height)
                                .keyboardType(.decimalPad)
                            Text(appState.unitPreference == .metric ? "cm" : "in")
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
                            Text(appState.unitPreference == .metric ? "km" : "miles")
                                .foregroundColor(ColorTheme.textSecondary)
                        }
                    } else {
                        ProfileInfoRow(label: "Name", value: appState.userProfile.name)
                        ProfileInfoRow(label: "Age", value: "\(appState.userProfile.age) years")
                        ProfileInfoRow(label: "Weight", value: appState.formatWeight(appState.userProfile.weight))
                        ProfileInfoRow(label: "Height", value: appState.formatHeight(appState.userProfile.height))
                        ProfileInfoRow(label: "Experience", value: appState.userProfile.experience.rawValue)
                        ProfileInfoRow(label: "Weekly Goal", value: appState.formatDistance(Double(appState.userProfile.weeklyGoal)))
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
                
                // Measurement Units
                Section(header: Text("Measurement Units")) {
                    Toggle(isOn: Binding(
                        get: { appState.unitPreference == .imperial },
                        set: { appState.unitPreference = $0 ? .imperial : .metric }
                    )) {
                        HStack {
                            Text("Imperial Units")
                            Spacer()
                            Text("(miles, pounds, feet)")
                                .font(.caption)
                                .foregroundColor(ColorTheme.textSecondary)
                        }
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
                
                // Logout section
                Section {
                    Button(action: {
                        showingLogoutConfirmation = true
                    }) {
                        HStack {
                            Spacer()
                            Label("Logout", systemImage: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(ColorTheme.error)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                resetLocalState()
            }
            .alert(isPresented: $showingLogoutConfirmation) {
                Alert(
                    title: Text("Logout"),
                    message: Text("Are you sure you want to logout?"),
                    primaryButton: .destructive(Text("Logout")) {
                        appState.logout()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    
    private func resetLocalState() {
        name = appState.userProfile.name
        age = "\(appState.userProfile.age)"
        
        // Convert values based on current unit preference
        if appState.unitPreference == .metric {
            weight = "\(appState.userProfile.weight)"
            height = "\(appState.userProfile.height)"
            weeklyGoal = "\(appState.userProfile.weeklyGoal)"
        } else {
            // Convert from metric to imperial
            weight = String(format: "%.1f", appState.userProfile.weight * 2.20462) // kg to lbs
            height = String(format: "%.1f", appState.userProfile.height * 0.393701) // cm to inches
            weeklyGoal = String(format: "%.1f", Double(appState.userProfile.weeklyGoal) * 0.621371) // km to miles
        }
        
        experience = appState.userProfile.experience
    }
    
    private func saveChanges() {
        // Update app state with edited values
        // In a real app, we would validate inputs and handle errors
        
        let ageValue = Int(age) ?? appState.userProfile.age
        var weightValue = Double(weight) ?? appState.userProfile.weight
        var heightValue = Double(height) ?? appState.userProfile.height
        var goalValue = Int(weeklyGoal) ?? appState.userProfile.weeklyGoal
        
        // Convert from imperial to metric if needed
        if appState.unitPreference == .imperial {
            weightValue = weightValue / 2.20462 // lbs to kg
            heightValue = heightValue / 0.393701 // inches to cm
            goalValue = Int(Double(goalValue) / 0.621371) // miles to km
        }
        
        let updatedProfile = UserProfile(
            name: name,
            age: ageValue,
            weight: weightValue,
            height: heightValue,
            experience: experience,
            weeklyGoal: goalValue
        )
        
        appState.userProfile = updatedProfile
        
        // If we have a current user, update their profile too
        if var user = appState.currentUser {
            user.profile = updatedProfile
            appState.currentUser = user
        }
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