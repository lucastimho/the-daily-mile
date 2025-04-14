import Foundation

struct UserProfile {
    var id = UUID()
    var name: String
    var age: Int
    var weight: Double // in kg
    var height: Double // in cm
    var experience: RunnerExperience
    var weeklyGoal: Int // in miles
    
    enum RunnerExperience: String, CaseIterable, Identifiable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        
        var id: String { self.rawValue }
    }
    
    // Demo profiles based on personas
    static let demoProfiles = [
        UserProfile(name: "Emma", age: 25, weight: 60, height: 165, experience: .beginner, weeklyGoal: 10),
        UserProfile(name: "Michael", age: 35, weight: 75, height: 180, experience: .intermediate, weeklyGoal: 25),
        UserProfile(name: "Sarah", age: 42, weight: 65, height: 170, experience: .advanced, weeklyGoal: 40)
    ]
} 