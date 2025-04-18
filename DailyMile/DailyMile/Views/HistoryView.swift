import SwiftUI
import MapKit
import CoreLocation

struct HistoryView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedDate: Date = Date()
    @State private var currentMonth: Date = Date()
    
    // Get workouts for the selected day
    var selectedDayWorkouts: [Workout] {
        let calendar = Calendar.current
        return appState.workouts.filter { workout in
            calendar.isDate(workout.date, inSameDayAs: selectedDate)
        }.sorted { $0.date > $1.date }
    }
    
    // Get workouts for the current month being viewed
    var currentMonthWorkouts: [Workout] {
        let calendar = Calendar.current
        
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!
        
        return appState.workouts.filter { workout in
            let workoutDate = workout.date
            return (workoutDate >= monthStart && workoutDate <= monthEnd)
        }
    }
    
    // Get dates that have workouts during the current displayed month
    var datesWithWorkouts: [Date] {
        let calendar = Calendar.current
        
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!
        
        return appState.workouts
            .filter { workout in
                let workoutDate = workout.date
                return (workoutDate >= monthStart && workoutDate <= monthEnd)
            }
            .map { workout in
                // Return only the day component (strip time)
                let components = calendar.dateComponents([.year, .month, .day], from: workout.date)
                return calendar.date(from: components)!
            }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Calendar view with month title
                VStack(spacing: 16) {
                    CalendarHeaderView(currentMonth: $currentMonth)
                    
                    // Monthly statistics
                    HStack(spacing: 16) {
                        HistoryStatCard(
                            title: "Runs",
                            value: "\(currentMonthWorkouts.count)",
                            icon: "figure.run",
                            color: ColorTheme.info
                        )
                        
                        HistoryStatCard(
                            title: "Distance",
                            value: String(format: "%.1f", totalMonthDistance()) + 
                                  (appState.unitPreference == .metric ? " km" : " mi"),
                            icon: "map",
                            color: ColorTheme.success
                        )
                        
                        HistoryStatCard( 
                            title: "Avg Pace",
                            value: averageMonthPace(),
                            icon: "speedometer",
                            color: ColorTheme.secondary
                        )
                    }
                    .padding(.horizontal)
                    
                    CalendarGridView(
                        currentMonth: currentMonth,
                        selectedDate: $selectedDate,
                        datesWithWorkouts: datesWithWorkouts
                    )
                    .padding(.horizontal, 8)
                }
                .padding(.top)
                .background(ColorTheme.background)
                
                Divider()
                    .padding(.vertical, 8)
                
                // Workouts for selected day
                VStack(alignment: .leading) {
                    Text(formattedSelectedDate())
                        .font(.headline)
                        .foregroundColor(ColorTheme.textPrimary)
                        .padding(.horizontal)
                    
                    if selectedDayWorkouts.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "figure.run")
                                .font(.system(size: 40))
                                .foregroundColor(ColorTheme.textSecondary)
                            
                            Text("No workouts on this day")
                                .font(.subheadline)
                                .foregroundColor(ColorTheme.textSecondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(selectedDayWorkouts) { workout in
                                    NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                        HistoryWorkoutCard(workout: workout)
                                            .padding(.horizontal)
                                    }
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .navigationTitle("History")
            .onChange(of: currentMonth) { _ in 
                // If changing to a month where the selected date isn't present, update selected date
                let calendar = Calendar.current
                let currentMonthComponents = calendar.dateComponents([.year, .month], from: currentMonth)
                let selectedDateComponents = calendar.dateComponents([.year, .month], from: selectedDate)
                
                if currentMonthComponents.year != selectedDateComponents.year || 
                   currentMonthComponents.month != selectedDateComponents.month {
                    selectedDate = currentMonth
                }
            }
        }
    }
    
    // Calculate the total distance for the current month
    func totalMonthDistance() -> Double {
        currentMonthWorkouts.reduce(0) { $0 + $1.distance }
    }
    
    // Calculate the average pace for the current month
    func averageMonthPace() -> String {
        guard !currentMonthWorkouts.isEmpty else { return "--:--" }
        
        let totalSeconds = currentMonthWorkouts.reduce(0.0) { $0 + $1.avgPace * $1.distance }
        let totalDistance = currentMonthWorkouts.reduce(0.0) { $0 + $1.distance }
        
        if totalDistance == 0 { return "--:--" }
        
        let avgPaceSeconds = totalSeconds / totalDistance
        let minutes = Int(avgPaceSeconds) / 60
        let seconds = Int(avgPaceSeconds) % 60
        
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func formattedSelectedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: selectedDate)
    }
}

// Calendar header with month title and navigation buttons
struct CalendarHeaderView: View {
    @Binding var currentMonth: Date
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        HStack {
            Text(dateFormatter.string(from: currentMonth))
                .font(.headline)
                .foregroundColor(ColorTheme.textPrimary)
            
            Spacer()
            
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .foregroundColor(ColorTheme.primary)
            }
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .foregroundColor(ColorTheme.primary)
            }
        }
        .padding(.horizontal)
    }
    
    private func previousMonth() {
        let calendar = Calendar.current
        if let date = calendar.date(byAdding: .month, value: -1, to: currentMonth) {
            currentMonth = date
        }
    }
    
    private func nextMonth() {
        let calendar = Calendar.current
        if let date = calendar.date(byAdding: .month, value: 1, to: currentMonth) {
            // Don't allow navigation to future months
            if date <= Date() {
                currentMonth = date
            }
        }
    }
}

// Calendar grid showing days
struct CalendarGridView: View {
    let currentMonth: Date
    @Binding var selectedDate: Date
    let datesWithWorkouts: [Date]
    
    private let calendar = Calendar.current
    private let daysOfWeek = ["Su", "Mo", "Tu", "We", "Th", "Fr", "Sa"]
    
    var body: some View {
        VStack(spacing: 12) {
            // Days of week
            HStack {
                ForEach(daysOfWeek, id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Day grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 10) {
                ForEach(days(), id: \.self) { date in
                    if let date = date {
                        DayCell(date: date, 
                                isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                                hasWorkout: hasWorkoutOnDate(date))
                            .onTapGesture {
                                selectedDate = date
                            }
                    } else {
                        // Empty cell for days not in current month
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
    }
    
    // Generate array of dates for the month, with nil for padding
    private func days() -> [Date?] {
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth))!
        let monthEnd = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: monthStart)!
        
        let daysInMonth = calendar.component(.day, from: monthEnd)
        
        // Get weekday of first day (0 = Sunday, 6 = Saturday)
        let firstWeekday = calendar.component(.weekday, from: monthStart) - 1
        
        // Create padding for days before the first of the month
        var days = Array(repeating: nil as Date?, count: firstWeekday)
        
        // Add all days of the month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: monthStart) {
                days.append(date)
            }
        }
        
        return days
    }
    
    private func hasWorkoutOnDate(_ date: Date) -> Bool {
        return datesWithWorkouts.contains { calendar.isDate($0, inSameDayAs: date) }
    }
}

// Individual day cell in the calendar
struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let hasWorkout: Bool
    
    private let calendar = Calendar.current
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(height: 40)
            
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16))
                .foregroundColor(textColor)
        }
    }
    
    private var isToday: Bool {
        calendar.isDateInToday(date)
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return ColorTheme.primary
        } else if isToday {
            return ColorTheme.primary.opacity(0.3)
        } else if hasWorkout {
            return ColorTheme.success.opacity(0.3)
        } else {
            return Color.clear
        }
    }
    
    private var textColor: Color {
        if isSelected {
            return .white
        } else {
            return ColorTheme.textPrimary
        }
    }
}

// Renamed from WorkoutCard to HistoryWorkoutCard to avoid duplication
struct HistoryWorkoutCard: View {
    @EnvironmentObject var appState: AppState
    let workout: Workout
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Time
                HStack {
                    Image(systemName: "clock")
                        .foregroundColor(ColorTheme.primary)
                    
                    Text(formattedTime())
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.textPrimary)
                }
                
                Spacer()
                
                // Distance with icon
                HStack {
                    Image(systemName: "ruler")
                        .foregroundColor(ColorTheme.success)
                    
                    Text(appState.formatDistance(workout.distance))
                        .font(.headline)
                        .foregroundColor(ColorTheme.textPrimary)
                }
            }
            
            Divider()
            
            // Stats
            HStack(spacing: 20) {
                // Duration
                VStack(alignment: .leading, spacing: 4) {
                    Text("Duration")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    Text(workout.formattedDuration)
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.textPrimary)
                }
                
                // Pace
                VStack(alignment: .leading, spacing: 4) {
                    Text("Avg Pace")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    Text(appState.formatPace(workout.avgPace))
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.textPrimary)
                }
                
                // Calories
                VStack(alignment: .leading, spacing: 4) {
                    Text("Calories")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    Text("\(workout.calories)")
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.textPrimary)
                }
                
                Spacer()
            }
            
            // Notes if available
            if let notes = workout.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundColor(ColorTheme.textSecondary)
                    .lineLimit(2)
                    .padding(.top, 4)
            }
        }
        .padding()
        .background(ColorTheme.cardBackground)
        .cornerRadius(12)
    }
    
    func formattedTime() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: workout.date)
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

struct WorkoutDetailView: View {
    @EnvironmentObject var appState: AppState
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
                    DetailStatCard(title: "Distance", value: appState.formatDistance(workout.distance), unit: "")
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
                        
                        Text(appState.formatPace(workout.avgPace))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(ColorTheme.textPrimary)
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
                if workout.route != nil && !workout.route!.isEmpty {
                    // Use actual route if available
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Route")
                            .font(.headline)
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        RouteMapView(
                            region: calculateRegion(from: workout.route!), 
                            coordinates: workout.route!
                        )
                        .frame(height: 200)
                        .cornerRadius(12)
                    }
                } else {
                    // Show placeholder if no route data
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
    
    // Calculate map region from workout route
    func calculateRegion(from coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
        
        var minLat = coordinates[0].latitude
        var maxLat = coordinates[0].latitude
        var minLon = coordinates[0].longitude
        var maxLon = coordinates[0].longitude
        
        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }
        
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLat - minLat) * 1.5,
            longitudeDelta: (maxLon - minLon) * 1.5
        )
        
        return MKCoordinateRegion(center: center, span: span)
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