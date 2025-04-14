import Foundation
import SwiftUI

class AppState: ObservableObject {
    @Published var currentUser: UserProfile
    @Published var workouts: [Workout]
    @Published var isRunning: Bool = false
    @Published var currentRunTime: TimeInterval = 0
    @Published var currentRunDistance: Double = 0
    @Published var isDemoMode: Bool = true
    
    init(demoMode: Bool = true) {
        self.isDemoMode = demoMode
        if demoMode {
            // Use demo data for preview
            self.currentUser = UserProfile.demoProfiles[0]
            self.workouts = Workout.demoWorkouts
        } else {
            // In a real app, we would load from persistent storage
            self.currentUser = UserProfile(name: "", age: 0, weight: 0, height: 0, experience: .beginner, weeklyGoal: 0)
            self.workouts = []
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
        return min(distanceThisWeek / Double(currentUser.weeklyGoal), 1.0)
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