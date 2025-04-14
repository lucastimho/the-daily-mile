import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedTimeFrame: TimeFrame = .all
    
    enum TimeFrame: String, CaseIterable, Identifiable {
        case week = "This Week"
        case month = "This Month"
        case all = "All Time"
        
        var id: String { self.rawValue }
    }
    
    var filteredWorkouts: [Workout] {
        let calendar = Calendar.current
        let now = Date()
        
        switch selectedTimeFrame {
        case .week:
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            return appState.workouts.filter { $0.date >= weekStart }
        case .month:
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            return appState.workouts.filter { $0.date >= monthStart }
        case .all:
            return appState.workouts
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Statistics summary
                VStack(spacing: 20) {
                    HStack {
                        Picker("Time Frame", selection: $selectedTimeFrame) {
                            ForEach(TimeFrame.allCases) { timeFrame in
                                Text(timeFrame.rawValue).tag(timeFrame)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .padding(.horizontal)
                    
                    HStack(spacing: 16) {
                        HistoryStatCard(
                            title: "Total Runs",
                            value: "\(filteredWorkouts.count)",
                            icon: "figure.run",
                            color: ColorTheme.info
                        )
                        
                        HistoryStatCard(
                            title: "Distance",
                            value: String(format: "%.1f mi", totalDistance()),
                            icon: "map",
                            color: ColorTheme.success
                        )
                        
                        HistoryStatCard(
                            title: "Avg Pace",
                            value: averagePace(),
                            icon: "speedometer",
                            color: ColorTheme.secondary
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
                .background(ColorTheme.background)
                
                Divider()
                
                // Workout list
                if filteredWorkouts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "figure.run")
                            .font(.system(size: 50))
                            .foregroundColor(ColorTheme.textSecondary)
                        
                        Text("No workouts yet")
                            .font(.headline)
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        Text("Your completed runs will appear here")
                            .font(.subheadline)
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(ColorTheme.background)
                } else {
                    List {
                        ForEach(filteredWorkouts) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                WorkoutListItem(workout: workout)
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                }
            }
            .navigationTitle("History")
        }
    }
    
    func totalDistance() -> Double {
        filteredWorkouts.reduce(0) { $0 + $1.distance }
    }
    
    func averagePace() -> String {
        guard !filteredWorkouts.isEmpty else { return "--:--" }
        
        let totalSeconds = filteredWorkouts.reduce(0.0) { $0 + $1.avgPace * $1.distance }
        let totalDistance = filteredWorkouts.reduce(0.0) { $0 + $1.distance }
        
        if totalDistance == 0 { return "--:--" }
        
        let avgPaceSeconds = totalSeconds / totalDistance
        let minutes = Int(avgPaceSeconds) / 60
        let seconds = Int(avgPaceSeconds) % 60
        
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct HistoryStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(ColorTheme.textPrimary)
            
            Text(title)
                .font(.caption)
                .foregroundColor(ColorTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(ColorTheme.cardBackground)
        .cornerRadius(12)
    }
}

struct WorkoutListItem: View {
    let workout: Workout
    
    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(formattedDate())
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)
                
                if let notes = workout.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "%.1f mi", workout.distance))
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)
                
                Text(workout.formattedPace)
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)
            }
        }
        .padding(.vertical, 8)
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: workout.date)
    }
}

struct WorkoutDetailView: View {
    let workout: Workout
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Date header
                Text(formattedDate())
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(ColorTheme.cardBackground)
                    .cornerRadius(12)
                
                // Quick stats
                HStack(spacing: 16) {
                    DetailStatCard(title: "Distance", value: String(format: "%.2f", workout.distance), unit: "mi")
                    DetailStatCard(title: "Duration", value: workout.formattedDuration, unit: "")
                    DetailStatCard(title: "Calories", value: "\(workout.calories)", unit: "cal")
                }
                
                // Pace
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pace")
                        .font(.headline)
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    HStack {
                        Image(systemName: "speedometer")
                            .foregroundColor(ColorTheme.secondary)
                        
                        Text(workout.formattedPace)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        Text("per mile")
                            .font(.subheadline)
                            .foregroundColor(ColorTheme.textSecondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(ColorTheme.cardBackground)
                    .cornerRadius(12)
                }
                
                // Notes
                if let notes = workout.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        Text(notes)
                            .foregroundColor(ColorTheme.textPrimary)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(ColorTheme.cardBackground)
                            .cornerRadius(12)
                    }
                }
                
                // Map placeholder (for demo)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Route")
                        .font(.headline)
                        .foregroundColor(ColorTheme.textPrimary)
                    
                    Image(systemName: "map")
                        .font(.system(size: 50))
                        .foregroundColor(ColorTheme.textSecondary)
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .background(ColorTheme.cardBackground)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .navigationTitle("Workout Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func formattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .short
        return formatter.string(from: workout.date)
    }
}

struct DetailStatCard: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(ColorTheme.textSecondary)
            
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(ColorTheme.textPrimary)
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(ColorTheme.cardBackground)
        .cornerRadius(12)
    }
}

#Preview {
    HistoryView()
        .environmentObject(AppState(demoMode: true))
} 