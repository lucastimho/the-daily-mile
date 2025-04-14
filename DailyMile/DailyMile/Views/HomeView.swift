import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Welcome header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Welcome, \(appState.currentUser.name)")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("Let's achieve your running goals!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Weekly progress
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Progress")
                            .font(.headline)
                        
                        WeeklyProgressView()
                    }
                    .padding(.horizontal)
                    
                    // Quick stats
                    HStack(spacing: 16) {
                        StatCard(
                            title: "This Week",
                            value: String(format: "%.1f mi", appState.totalDistanceThisWeek()),
                            icon: "figure.walk",
                            color: .blue
                        )
                        
                        StatCard(
                            title: "Last Run",
                            value: appState.workouts.first?.formattedPace ?? "-",
                            icon: "timer",
                            color: .orange
                        )
                        
                        StatCard(
                            title: "Goal",
                            value: "\(appState.currentUser.weeklyGoal) mi",
                            icon: "flag.fill",
                            color: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    // Recent workouts
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Workouts")
                            .font(.headline)
                        
                        ForEach(appState.workouts.prefix(3)) { workout in
                            WorkoutCard(workout: workout)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Daily Mile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct WeeklyProgressView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("\(String(format: "%.1f", appState.totalDistanceThisWeek())) of \(appState.currentUser.weeklyGoal) miles")
                    .font(.subheadline)
                
                Spacer()
                
                Text("\(Int(appState.weeklyGoalProgress() * 100))%")
                    .font(.headline)
                    .foregroundColor(.green)
            }
            
            ProgressBar(value: appState.weeklyGoalProgress())
                .frame(height: 10)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct WorkoutCard: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "figure.run")
                    .foregroundColor(.green)
                
                Text(formattedDate())
                    .font(.headline)
                
                Spacer()
                
                Text(String(format: "%.1f mi", workout.distance))
                    .fontWeight(.semibold)
            }
            
            HStack {
                Label(workout.formattedDuration, systemImage: "timer")
                    .font(.subheadline)
                
                Spacer()
                
                Label(workout.formattedPace, systemImage: "speedometer")
                    .font(.subheadline)
            }
            .foregroundColor(.secondary)
            
            if let notes = workout.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: workout.date)
    }
}

struct ProgressBar: View {
    var value: Double // between 0 and 1
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .foregroundColor(Color(.systemGray4))
                    .cornerRadius(5)
                
                Rectangle()
                    .foregroundColor(.green)
                    .frame(width: min(CGFloat(value) * geometry.size.width, geometry.size.width))
                    .cornerRadius(5)
            }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState(demoMode: true))
} 