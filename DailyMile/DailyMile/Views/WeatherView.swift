import SwiftUI

struct WeatherView: View {
    @ObservedObject var weatherService: WeatherService
    @State private var showingErrorInfo = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Current Weather")
                    .font(.headline)
                    .foregroundColor(ColorTheme.textPrimary)
                
                Spacer()
                
                if weatherService.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(0.8)
                }
            }
            
            // Weather data always shown regardless of errors
            HStack(spacing: 20) {
                // Temperature and condition
                VStack(alignment: .leading, spacing: 5) {
                    HStack(alignment: .top, spacing: 2) {
                        Text("\(Int(weatherService.temperature))")
                            .font(.system(size: 30, weight: .bold))
                            .foregroundColor(ColorTheme.textPrimary)
                        
                        Text("°F")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(ColorTheme.textSecondary)
                            .padding(.top, 2)
                    }
                    
                    Text(weatherService.condition)
                        .font(.subheadline)
                        .foregroundColor(ColorTheme.textSecondary)
                }
                
                Spacer()
                
                // Weather icon
                Image(systemName: weatherService.conditionIcon)
                    .font(.system(size: 36))
                    .foregroundColor(weatherIconColor(condition: weatherService.condition))
                    .symbolRenderingMode(.multicolor)
            }
            
            // Additional weather details
            HStack(spacing: 20) {
                // Feels like
                VStack(alignment: .leading, spacing: 2) {
                    Text("Feels like")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    Text("\(Int(weatherService.feelsLike))°F")
                        .font(.callout)
                        .foregroundColor(ColorTheme.textPrimary)
                }
                
                // Humidity
                VStack(alignment: .leading, spacing: 2) {
                    Text("Humidity")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    Text("\(weatherService.humidity)%")
                        .font(.callout)
                        .foregroundColor(ColorTheme.textPrimary)
                }
                
                // Wind
                VStack(alignment: .leading, spacing: 2) {
                    Text("Wind")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    Text("\(Int(weatherService.windSpeed)) mph")
                        .font(.callout)
                        .foregroundColor(ColorTheme.textPrimary)
                }
                
                Spacer()
            }
            
            // Show error message if there is one
            if let error = weatherService.errorMessage {
                Divider()
                    .padding(.vertical, 4)
                
                HStack(alignment: .center, spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(ColorTheme.warning)
                        .font(.caption)
                    
                    Text("Using simulated data")
                        .font(.caption)
                        .foregroundColor(ColorTheme.textSecondary)
                    
                    Spacer()
                    
                    Button {
                        showingErrorInfo.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(ColorTheme.textSecondary)
                            .font(.caption)
                    }
                    .popover(isPresented: $showingErrorInfo) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Weather API Error")
                                .font(.headline)
                            
                            Text(error)
                                .font(.caption)
                            
                            Divider()
                            
                            Text("Showing simulated weather data instead.")
                                .font(.caption)
                        }
                        .padding()
                        .frame(width: 250)
                    }
                }
            }
        }
        .padding(15)
        .background(ColorTheme.cardBackground)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    // Return appropriate color based on weather condition
    private func weatherIconColor(condition: String) -> Color {
        switch condition.lowercased() {
        case _ where condition.contains("clear"):
            return .yellow
        case _ where condition.contains("cloud"):
            return .gray
        case _ where condition.contains("rain") || condition.contains("drizzle"):
            return .blue
        case _ where condition.contains("snow"):
            return .cyan
        case _ where condition.contains("thunderstorm"):
            return .purple
        default:
            return .blue
        }
    }
}

// Simplified preview without any local variables to avoid buildExpression errors
struct WeatherView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Normal weather preview
            WeatherView(weatherService: createDemoWeatherService(withError: false))
                .padding()
                .previewDisplayName("Normal Weather")
            
            // Error weather preview
            WeatherView(weatherService: createDemoWeatherService(withError: true))
                .padding()
                .previewDisplayName("Error Weather")
        }
        .background(ColorTheme.background)
    }
    
    // Helper function to create demo weather service
    static func createDemoWeatherService(withError: Bool) -> WeatherService {
        let service = WeatherService()
        service.temperature = 72.5
        service.feelsLike = 74.0
        service.condition = "Partly Cloudy"
        service.conditionIcon = "cloud.sun"
        service.humidity = 65
        service.windSpeed = 8.5
        
        if withError {
            service.errorMessage = "API key invalid or expired"
        }
        
        return service
    }
} 