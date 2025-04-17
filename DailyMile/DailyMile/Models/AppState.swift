import Foundation
import SwiftUI

// Theme mode enum
enum ThemeMode: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"
    
    var id: String { self.rawValue }
}

class AppState: ObservableObject {
    // Authentication state
    @Published var isLoggedIn: Bool = false
    @Published var currentUser: User?
    @Published var loginError: String?
    @Published var signupError: String?
    
    // User profile data
    @Published var userProfile: UserProfile
    @Published var workouts: [Workout]
    
    // App state
    @Published var isRunning: Bool = false
    @Published var currentRunTime: TimeInterval = 0
    @Published var currentRunDistance: Double = 0
    @Published var isDemoMode: Bool = true
    @Published var themeMode: ThemeMode = .system
    
    // Demo user storage - in a real app this would be persistent
    @Published var users: [User]
    
    // Theme color scheme computed property
    @Published var colorScheme: ColorScheme? = nil
    
    init(demoMode: Bool = true) {
        self.isDemoMode = demoMode
        self.users = User.demoUsers // Start with demo users
        
        if demoMode {
            // Use demo data for preview - but not logged in yet
            self.userProfile = UserProfile.demoProfiles[0]
            self.workouts = Workout.demoWorkouts
        } else {
            // In a real app, we would load from persistent storage
            self.userProfile = UserProfile(name: "", age: 0, weight: 0, height: 0, experience: .beginner, weeklyGoal: 0)
            self.workouts = []
        }
    }
    
    // Login method
    func login(username: String, password: String) {
        if let user = User.authenticate(username: username, password: password, users: users) {
            currentUser = user
            userProfile = user.profile
            isLoggedIn = true
            loginError = nil
        } else {
            loginError = "Invalid username or password"
        }
    }
    
    // Signup method
    func signup(username: String, password: String, confirmPassword: String, profile: UserProfile) -> Bool {
        // Clear previous errors
        signupError = nil
        
        // Validate username
        if username.isEmpty {
            signupError = "Username cannot be empty"
            return false
        }
        
        // Check if username already exists
        if users.contains(where: { $0.username.lowercased() == username.lowercased() }) {
            signupError = "Username already exists"
            return false
        }
        
        // Validate password
        if password.isEmpty {
            signupError = "Password cannot be empty"
            return false
        }
        
        if password.count < 6 {
            signupError = "Password must be at least 6 characters"
            return false
        }
        
        // Confirm passwords match
        if password != confirmPassword {
            signupError = "Passwords do not match"
            return false
        }
        
        // Create the new user
        let newUser = User(
            username: username,
            password: password,
            profile: profile
        )
        
        // Add the user to our collection
        users.append(newUser)
        
        // Auto-login the user
        currentUser = newUser
        userProfile = profile
        isLoggedIn = true
        
        return true
    }
    
    // Logout method
    func logout() {
        isLoggedIn = false
        currentUser = nil
        loginError = nil
    }
    
    // Update the color scheme based on theme mode
    func updateColorScheme() {
        switch themeMode {
        case .light:
            colorScheme = .light
        case .dark:
            colorScheme = .dark
        case .system:
            colorScheme = nil // Use system default
        }
    }
    
    func totalDistanceThisWeek() -> Double {
        let calendar = Calendar.current
        let weekStart = calendar.startOfDay(for: calendar.date(byAdding: .day, value: -7, to: Date())!)
        
        return workouts
            .filter { $0.date >= weekStart }
            .reduce(0) { $0 + $1.distance }
    }
    
    func weeklyGoalProgress() -> Double {
        let distanceThisWeek = totalDistanceThisWeek()
        return min(distanceThisWeek / Double(userProfile.weeklyGoal), 1.0)
    }
    
    func addWorkout(_ workout: Workout) {
        workouts.append(workout)
        // In a real app, we would save to persistent storage
    }
    
    // Simulate GPS tracking in demo mode
    func startDemoRun() {
        isRunning = true
        currentRunTime = 0
        currentRunDistance = 0
        
        // In a real app, this would use actual GPS data
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self, self.isRunning else {
                timer.invalidate()
                return
            }
            
            self.currentRunTime += 1
            // Simulate a 10-minute mile pace
            self.currentRunDistance += 1 / 600
        }
    }
    
    // Start a real run with location tracking
    func startRun() {
        isRunning = true
        currentRunTime = 0
        
        // Timer for tracking elapsed time
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self, self.isRunning else {
                timer.invalidate()
                return
            }
            
            self.currentRunTime += 1
        }
    }
    
    func stopRun() {
        guard isRunning else { return }
        isRunning = false
        
        // Create a new workout from the run data
        let avgPace = currentRunDistance > 0 ? currentRunTime / currentRunDistance : 0
        let calories = Int(currentRunDistance * 100) // Simple calorie estimation
        
        let workout = Workout(
            date: Date(),
            distance: currentRunDistance,
            duration: currentRunTime,
            route: nil,
            calories: calories,
            avgPace: avgPace,
            notes: nil
        )
        
        addWorkout(workout)
        
        // Reset current run data
        currentRunTime = 0
        currentRunDistance = 0
    }
} 