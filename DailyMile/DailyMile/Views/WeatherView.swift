import SwiftUI

struct WeatherView: View {
    @ObservedObject var weatherService: WeatherService
    
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
            
            if let error = weatherService.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(ColorTheme.error)
                    .padding(.top, 4)
            } else {
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

#Preview {
    let weatherService = WeatherService()
    // Set some demo values
    weatherService.temperature = 72.5
    weatherService.feelsLike = 74.0
    weatherService.condition = "Partly Cloudy"
    weatherService.conditionIcon = "cloud.sun"
    weatherService.humidity = 65
    weatherService.windSpeed = 8.5
    
    return VStack {
        WeatherView(weatherService: weatherService)
            .padding()
        Spacer()
    }
    .background(ColorTheme.background)
} 