import Foundation
import MapKit

struct Workout: Identifiable {
    var id = UUID()
    var date: Date
    var distance: Double // in miles
    var duration: TimeInterval // in seconds
    var route: [CLLocationCoordinate2D]?
    var calories: Int
    var avgPace: TimeInterval // seconds per mile
    var notes: String?
    
    var formattedDuration: String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    var formattedPace: String {
        let minutes = Int(avgPace) / 60
        let seconds = Int(avgPace) % 60
        return String(format: "%d:%02d /mi", minutes, seconds)
    }
    
    // Demo workouts for app preview
    static let demoWorkouts = [
        Workout(
            date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
            distance: 3.1,
            duration: 1800,
            route: nil,
            calories: 250,
            avgPace: 580,
            notes: "Morning run, felt good"
        ),
        Workout(
            date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
            distance: 5.0,
            duration: 2700,
            route: nil,
            calories: 400,
            avgPace: 540,
            notes: "Evening run in the park"
        ),
        Workout(
            date: Calendar.current.date(byAdding: .day, value: -6, to: Date())!,
            distance: 6.2,
            duration: 3300,
            route: nil,
            calories: 520,
            avgPace: 532,
            notes: "10K training run"
        )
    ]
} 