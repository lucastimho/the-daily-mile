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
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        Text("Let's achieve your running goals!")
                            .font(.subheadline)
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                    .padding(.horizontal)
                    
                    // Weekly progress
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Weekly Progress")
                            .font(.headline)
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        WeeklyProgressView()
                    }
                    .padding(.horizontal)
                    
                    // Quick stats
                    HStack(spacing: 16) {
                        StatCard(
                            title: "This Week",
                            value: String(format: "%.1f mi", appState.totalDistanceThisWeek()),
                            icon: "figure.walk",
                            color: ColorTheme.info
                        )
                        
                        StatCard(
                            title: "Last Run",
                            value: appState.workouts.first?.formattedPace ?? "-",
                            icon: "timer",
                            color: ColorTheme.secondary
                        )
                        
                        StatCard(
                            title: "Goal",
                            value: "\(appState.currentUser.weeklyGoal) mi",
                            icon: "flag.fill",
                            color: ColorTheme.primary
                        )
                    }
                    .padding(.horizontal)
                    
                    // Recent workouts
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Workouts")
                            .font(.headline)
                            .foregroundColor(ColorTheme.textPrimary)
                        
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
            .background(ColorTheme.background)
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
                    .foregroundColor(ColorTheme.textPrimary)
                
                Spacer()
                
                Text("\(Int(appState.weeklyGoalProgress() * 100))%")
                    .font(.headline)
                    .foregroundColor(ColorTheme.primary)
            }
            
            ProgressBar(value: appState.weeklyGoalProgress())
                .frame(height: 10)
        }
        .padding()
        .background(ColorTheme.cardBackground)
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
                    .foregroundColor(ColorTheme.textSecondary)
            }
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.textPrimary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ColorTheme.cardBackground)
        .cornerRadius(12)
    }
}

struct WorkoutCard: View {
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "figure.run")
                    .foregroundColor(ColorTheme.primary)
                
                Text(formattedDate())
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)
                
                Spacer()
                
                Text(String(format: "%.1f mi", workout.distance))
                    .fontWeight(.semibold)
                    .foregroundColor(ColorTheme.textPrimary)
            }
            
            HStack {
                Label(workout.formattedDuration, systemImage: "timer")
                    .font(.subheadline)
                
                Spacer()
                
                Label(workout.formattedPace, systemImage: "speedometer")
                    .font(.subheadline)
            }
            .foregroundColor(ColorTheme.textSecondary)
            
            if let notes = workout.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(ColorTheme.cardBackground)
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
                    .foregroundColor(ColorTheme.primary)
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