import SwiftUI
import MapKit

struct RunView: View {
    @EnvironmentObject var appState: AppState
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var showingPostRunSummary = false
    @State private var tempWorkout: Workout?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Map view (in demo mode, this would show a static map)
                Map(coordinateRegion: $region)
                    .frame(maxWidth: .infinity)
                    .frame(height: 250)
                    .disabled(true) // Disabled in demo mode
                
                // Current run stats
                VStack(spacing: 24) {
                    HStack(spacing: 20) {
                        RunStatView(title: "DISTANCE", value: String(format: "%.2f", appState.currentRunDistance), unit: "MI")
                        
                        RunStatView(title: "TIME", value: formattedTime(appState.currentRunTime), unit: "")
                        
                        RunStatView(title: "PACE", value: currentPace(), unit: "/MI")
                    }
                    .padding(.top, 24)
                    
                    Spacer()
                    
                    // Run controls
                    if appState.isRunning {
                        Button(action: {
                            appState.stopRun()
                            // Create temporary workout for summary
                            let avgPace = appState.currentRunDistance > 0 ? appState.currentRunTime / appState.currentRunDistance : 0
                            tempWorkout = Workout(
                                date: Date(),
                                distance: appState.currentRunDistance,
                                duration: appState.currentRunTime,
                                route: nil,
                                calories: Int(appState.currentRunDistance * 100),
                                avgPace: avgPace,
                                notes: nil
                            )
                            showingPostRunSummary = true
                        }) {
                            Text("STOP")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorTheme.error)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
                    } else {
                        Button(action: {
                            // In demo mode, start a simulated run
                            appState.startDemoRun()
                        }) {
                            Text("START RUN")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(ColorTheme.success)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
                    }
                }
                .frame(maxHeight: .infinity)
                .background(ColorTheme.background)
            }
            
            // Demo mode indicator
            VStack {
                HStack {
                    Spacer()
                    
                    Text("DEMO MODE")
                        .font(.caption)
                        .padding(5)
                        .background(ColorTheme.warning.opacity(0.7))
                        .cornerRadius(5)
                        .padding(5)
                }
                
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationTitle("Run")
        .navigationBarHidden(true)
        .sheet(isPresented: $showingPostRunSummary) {
            if let workout = tempWorkout {
                RunSummaryView(workout: workout)
                    .environmentObject(appState)
            }
        }
    }
    
    func formattedTime(_ timeInterval: TimeInterval) -> String {
        let hours = Int(timeInterval) / 3600
        let minutes = Int(timeInterval) % 3600 / 60
        let seconds = Int(timeInterval) % 60
        
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    func currentPace() -> String {
        guard appState.currentRunDistance > 0 else { return "--:--" }
        
        let paceSeconds = appState.currentRunTime / appState.currentRunDistance
        let minutes = Int(paceSeconds) / 60
        let seconds = Int(paceSeconds) % 60
        
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct RunStatView: View {
    let title: String
    let value: String
    let unit: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(ColorTheme.textSecondary)
            
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(ColorTheme.textPrimary)
            
            Text(unit)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(ColorTheme.textSecondary)
        }
    }
}

struct RunSummaryView: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.presentationMode) var presentationMode
    let workout: Workout
    @State private var notes: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Run Summary")) {
                    HStack {
                        Text("Distance")
                        Spacer()
                        Text("\(String(format: "%.2f", workout.distance)) miles")
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Duration")
                        Spacer()
                        Text(workout.formattedDuration)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Avg. Pace")
                        Spacer()
                        Text(workout.formattedPace)
                            .fontWeight(.semibold)
                    }
                    
                    HStack {
                        Text("Calories")
                        Spacer()
                        Text("\(workout.calories)")
                            .fontWeight(.semibold)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: $notes)
                        .frame(height: 100)
                }
                
                Section {
                    Button("Save Workout") {
                        var updatedWorkout = workout
                        updatedWorkout.notes = notes.isEmpty ? nil : notes
                        appState.addWorkout(updatedWorkout)
                        presentationMode.wrappedValue.dismiss()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(ColorTheme.success)
                }
            }
            .navigationTitle("Workout Complete!")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    RunView()
        .environmentObject(AppState(demoMode: true))
} 