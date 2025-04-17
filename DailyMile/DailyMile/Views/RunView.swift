import SwiftUI
import MapKit
import CoreLocation

// Custom map view with route overlay
struct RouteMapView: UIViewRepresentable {
    var region: MKCoordinateRegion
    var coordinates: [CLLocationCoordinate2D]
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.region = region
        mapView.showsUserLocation = true
        
        // Customize the user location appearance
        mapView.tintColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0) // Vibrant blue
        
        return mapView
    }
    
    func updateUIView(_ view: MKMapView, context: Context) {
        view.region = region
        
        // Remove all overlays and add new ones
        view.removeOverlays(view.overlays)
        
        if coordinates.count >= 2 {
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            view.addOverlay(polyline)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 0.8)
                renderer.lineWidth = 5
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
        
        // Customize the user location annotation view
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                // Use a standard annotation view for the user location
                let identifier = "userLocation"
                var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
                
                if annotationView == nil {
                    annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                    annotationView?.canShowCallout = false
                } else {
                    annotationView?.annotation = annotation
                }
                
                // Create a custom user location marker
                let dotSize = CGSize(width: 24, height: 24)
                
                UIGraphicsBeginImageContextWithOptions(dotSize, false, 0.0)
                let context = UIGraphicsGetCurrentContext()
                
                // Draw outer circle (pulse effect)
                context?.setFillColor(UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 0.3).cgColor)
                context?.fillEllipse(in: CGRect(origin: .zero, size: dotSize))
                
                // Draw inner circle (location dot)
                let innerDotSize = CGSize(width: 12, height: 12)
                let innerDotOrigin = CGPoint(x: (dotSize.width - innerDotSize.width) / 2,
                                            y: (dotSize.height - innerDotSize.height) / 2)
                context?.setFillColor(UIColor(red: 0.0, green: 0.5, blue: 1.0, alpha: 1.0).cgColor)
                context?.fillEllipse(in: CGRect(origin: innerDotOrigin, size: innerDotSize))
                
                let image = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                annotationView?.image = image
                
                // Add pulsing animation if not already added
                if annotationView?.layer.animation(forKey: "pulse") == nil {
                    // Create pulsing layer
                    let pulseLayer = CALayer()
                    pulseLayer.frame = CGRect(x: 0, y: 0, width: dotSize.width, height: dotSize.height)
                    
                    // Create pulse animation
                    let pulseAnimation = CABasicAnimation(keyPath: "transform.scale")
                    pulseAnimation.fromValue = 1.0
                    pulseAnimation.toValue = 1.5
                    pulseAnimation.duration = 1.0
                    pulseAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    pulseAnimation.autoreverses = true
                    pulseAnimation.repeatCount = .infinity
                    
                    // Create opacity animation
                    let opacityAnimation = CABasicAnimation(keyPath: "opacity")
                    opacityAnimation.fromValue = 0.8
                    opacityAnimation.toValue = 0.0
                    opacityAnimation.duration = 1.0
                    opacityAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                    opacityAnimation.autoreverses = true
                    opacityAnimation.repeatCount = .infinity
                    
                    // Create animation group
                    let animationGroup = CAAnimationGroup()
                    animationGroup.animations = [pulseAnimation, opacityAnimation]
                    animationGroup.duration = 2.0
                    animationGroup.repeatCount = .infinity
                    
                    pulseLayer.add(animationGroup, forKey: "pulse")
                    
                    // Add the pulse layer
                    annotationView?.layer.addSublayer(pulseLayer)
                }
                
                return annotationView
            }
            return nil
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    @Published var location: CLLocation?
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    @Published var totalDistance: Double = 0
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10 // Update every 10 meters
        locationManager.activityType = .fitness
        locationManager.requestWhenInUseAuthorization()
        authorizationStatus = locationManager.authorizationStatus
    }
    
    func startTracking() {
        routeCoordinates = []
        totalDistance = 0
        locationError = nil
        
        // Check authorization before starting
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            locationError = "Location access denied. Please enable location permissions in Settings."
            // Request permission again
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func stopTracking() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Update latest location
        self.location = location
        
        // Update map region to center on user
        let newRegion = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        self.region = newRegion
        
        // Add to route
        routeCoordinates.append(location.coordinate)
        
        // Calculate distance if we have at least two locations
        if routeCoordinates.count > 1 {
            let previousLocation = CLLocation(
                latitude: routeCoordinates[routeCoordinates.count - 2].latitude,
                longitude: routeCoordinates[routeCoordinates.count - 2].longitude
            )
            
            // Distance in meters
            let distance = location.distance(from: previousLocation)
            
            // Add to total distance (converting to miles)
            totalDistance += distance / 1609.34
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationError = nil
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            locationError = "Location access denied. Please enable location permissions in Settings."
        case .notDetermined:
            locationError = "Location permissions not determined."
        @unknown default:
            locationError = "Unknown authorization status."
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError {
            switch error.code {
            case .denied:
                locationError = "Location access denied."
            case .network:
                locationError = "Network error. Please check your connection."
            default:
                locationError = "Location error: \(error.localizedDescription)"
            }
        } else {
            locationError = "Error getting location: \(error.localizedDescription)"
        }
    }
}

struct RunView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var locationManager = LocationManager()
    @State private var showingPostRunSummary = false
    @State private var tempWorkout: Workout?
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Map view with live location and route
                if appState.isDemoMode {
                    Map(coordinateRegion: $locationManager.region)
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        .disabled(true)
                } else {
                    ZStack {
                        RouteMapView(
                            region: locationManager.region,
                            coordinates: locationManager.routeCoordinates
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: 250)
                        
                        // Show error overlay if there's a location error
                        if let error = locationManager.locationError {
                            VStack {
                                Text(error)
                                    .font(.callout)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.black.opacity(0.7))
                                    .cornerRadius(8)
                                
                                Button("Open Settings") {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        UIApplication.shared.open(url)
                                    }
                                }
                                .padding(8)
                                .background(ColorTheme.primary)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                                .padding(.top, 5)
                            }
                            .padding()
                        }
                    }
                }
                
                // Current run stats
                VStack(spacing: 24) {
                    HStack(spacing: 20) {
                        RunStatView(
                            title: "DISTANCE", 
                            value: String(format: "%.2f", appState.isDemoMode ? appState.currentRunDistance : locationManager.totalDistance), 
                            unit: "MI"
                        )
                        
                        RunStatView(title: "TIME", value: formattedTime(appState.currentRunTime), unit: "")
                        
                        RunStatView(
                            title: "PACE", 
                            value: appState.isDemoMode ? currentPace() : currentLivePace(), 
                            unit: "/MI"
                        )
                    }
                    .padding(.top, 24)
                    
                    Spacer()
                    
                    // Run controls
                    if appState.isRunning {
                        Button(action: {
                            if appState.isDemoMode {
                                appState.stopRun()
                            } else {
                                locationManager.stopTracking()
                                appState.stopRun()
                            }
                            
                            // Create temporary workout for summary
                            let avgPace: Double
                            let distance: Double
                            
                            if appState.isDemoMode {
                                distance = appState.currentRunDistance
                                avgPace = distance > 0 ? appState.currentRunTime / distance : 0
                            } else {
                                distance = locationManager.totalDistance
                                avgPace = distance > 0 ? appState.currentRunTime / distance : 0
                            }
                            
                            tempWorkout = Workout(
                                date: Date(),
                                distance: distance,
                                duration: appState.currentRunTime,
                                route: appState.isDemoMode ? nil : locationManager.routeCoordinates,
                                calories: Int(distance * 100),
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
                            if appState.isDemoMode {
                                // In demo mode, start a simulated run
                                appState.startDemoRun()
                            } else {
                                // Start real location tracking
                                locationManager.startTracking()
                                appState.startRun()
                            }
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
            if appState.isDemoMode {
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
    
    func currentLivePace() -> String {
        guard locationManager.totalDistance > 0 else { return "--:--" }
        
        let paceSeconds = appState.currentRunTime / locationManager.totalDistance
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
    @State private var mapRegion: MKCoordinateRegion?
    
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
                
                // Show route map if available
                if let route = workout.route, !route.isEmpty {
                    Section(header: Text("Route")) {
                        VStack {
                            RouteMapView(
                                region: mapRegion ?? calculateRegion(from: route),
                                coordinates: route
                            )
                            .frame(height: 200)
                            .cornerRadius(8)
                        }
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
            .onAppear {
                if let route = workout.route, !route.isEmpty {
                    mapRegion = calculateRegion(from: route)
                }
            }
        }
    }
    
    // Calculate the map region to show the entire route
    private func calculateRegion(from coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
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

#Preview {
    RunView()
        .environmentObject(AppState(demoMode: true))
} 