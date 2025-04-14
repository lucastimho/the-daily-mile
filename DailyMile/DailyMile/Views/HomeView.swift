import SwiftUI

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var percentileMetric: PercentileMetric = .pace
    
    enum PercentileMetric: String, CaseIterable, Identifiable {
        case pace = "Pace"
        case distance = "Distance"
        
        var id: String { self.rawValue }
    }
    
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
                    
                    // Runner Percentile
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Runner Percentile")
                                .font(.headline)
                                .foregroundColor(ColorTheme.textPrimary)
                            
                            Spacer()
                            
                            Picker("Metric", selection: $percentileMetric) {
                                ForEach(PercentileMetric.allCases) { metric in
                                    Text(metric.rawValue).tag(metric)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .frame(width: 180)
                        }
                        
                        RunnerPercentileView(metric: percentileMetric)
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

struct RunnerPercentileView: View {
    let metric: HomeView.PercentileMetric
    @State private var animationProgress: CGFloat = 0
    
    // Static percentile data - would be calculated from actual data in a real app
    private var userPercentile: Int {
        switch metric {
        case .pace:
            return 75 // 75th percentile for pace (better than 75% of runners)
        case .distance:
            return 62 // 62nd percentile for distance
        }
    }
    
    private var labelText: String {
        switch metric {
        case .pace:
            return "Your pace is faster than \(userPercentile)% of runners"
        case .distance:
            return "Your distance is greater than \(userPercentile)% of runners"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(labelText)
                .font(.subheadline)
                .foregroundColor(ColorTheme.textPrimary)
            
            ZStack(alignment: .leading) {
                // Background track
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 20)
                    .foregroundColor(Color(.systemGray5))
                
                // Filled portion
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: animationProgress * CGFloat(userPercentile) / 100, height: 20)
                    .foregroundColor(percentileColor)
                
                // Percentile markers
                HStack {
                    ForEach([25, 50, 75, 100], id: \.self) { marker in
                        Spacer()
                        if marker != 100 {
                            Rectangle()
                                .frame(width: 1, height: 10)
                                .foregroundColor(Color(.systemGray3))
                        }
                    }
                }
                .padding(.horizontal, 4)
                
                // Interactive slider knob
                Circle()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.white)
                    .shadow(radius: 2)
                    .overlay(
                        Text("\(userPercentile)")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(Color(.darkGray))
                    )
                    .offset(x: (animationProgress * CGFloat(userPercentile) / 100) - 15)
            }
            .frame(height: 30)
            .overlay(
                GeometryReader { geometry in
                    Color.clear.preference(
                        key: WidthPreferenceKey.self,
                        value: geometry.size.width
                    )
                }
            )
            .onPreferenceChange(WidthPreferenceKey.self) { width in
                withAnimation(.easeOut(duration: 1.0)) {
                    self.animationProgress = width > 0 ? 1.0 : 0.0
                }
            }
            
            HStack {
                Text("Beginner")
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)
                
                Spacer()
                
                Text("Average")
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)
                
                Spacer()
                
                Text("Elite")
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)
            }
        }
        .padding()
        .background(ColorTheme.cardBackground)
        .cornerRadius(12)
        .onAppear {
            withAnimation(.easeOut(duration: 1.0).delay(0.3)) {
                animationProgress = 1.0
            }
        }
        .onChange(of: metric) { _ in
            // Reset and reanimate when changing metrics
            animationProgress = 0
            withAnimation(.easeOut(duration: 1.0)) {
                animationProgress = 1.0
            }
        }
    }
    
    private var percentileColor: Color {
        if userPercentile < 33 {
            return ColorTheme.warning
        } else if userPercentile < 66 {
            return ColorTheme.info
        } else {
            return ColorTheme.success
        }
    }
}

struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState(demoMode: true))
} 