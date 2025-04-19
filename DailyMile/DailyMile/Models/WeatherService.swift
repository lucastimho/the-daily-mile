import Foundation
import CoreLocation

class WeatherService: ObservableObject {
    @Published var temperature: Double = 0
    @Published var feelsLike: Double = 0
    @Published var condition: String = ""
    @Published var conditionIcon: String = "sun.max"
    @Published var humidity: Int = 0
    @Published var windSpeed: Double = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    // The API key - replace this with your actual key
    // Using a direct string here instead of accessing APIKeys to avoid compilation issues
    private let apiKey = "2a461a2a326e21e9593c790f1a79e5b0"
    
    // Track if we're using simulated data
    private var isUsingSimulatedData = false
    
    func fetchWeather(for location: CLLocation) {
        isLoading = true
        errorMessage = nil
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        // If using the demo key, simulate weather data
        if apiKey == "your_api_key_here" || apiKey == "demo_key" {
            simulateWeather()
            return
        }
        
        // Try to get real weather data
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=imperial&appid=\(apiKey)"
        print("📍 Fetching weather from: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            self.fallbackToSimulatedWeather(error: "Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    print("⚠️ Weather API network error: \(error.localizedDescription)")
                    self.fallbackToSimulatedWeather(error: "Network error: \(error.localizedDescription)")
                    return
                }
                
                // Check for HTTP errors
                if let httpResponse = response as? HTTPURLResponse {
                    print("📊 Weather API HTTP status code: \(httpResponse.statusCode)")
                    
                    if httpResponse.statusCode != 200 {
                        self.fallbackToSimulatedWeather(error: "HTTP error: \(httpResponse.statusCode)")
                        return
                    }
                }
                
                guard let data = data else {
                    print("⚠️ Weather API: No data received")
                    self.fallbackToSimulatedWeather(error: "No data received")
                    return
                }
                
                // Print the raw JSON data for debugging
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("🌤️ Weather API raw response: \(jsonString)")
                }
                
                do {
                    // Parse JSON response
                    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                    
                    // Check if response contains an error message
                    if let message = json?["message"] as? String {
                        print("⚠️ Weather API error message: \(message)")
                        self.fallbackToSimulatedWeather(error: "API error: \(message)")
                        return
                    }
                    
                    // Verify the structure of the JSON to help debugging
                    let hasMain = json?["main"] != nil
                    let hasWeather = (json?["weather"] as? [[String: Any]])?.first != nil
                    let hasWind = json?["wind"] != nil
                    
                    print("📋 Weather data structure check - main: \(hasMain), weather: \(hasWeather), wind: \(hasWind)")
                    
                    if let main = json?["main"] as? [String: Any],
                       let weatherArray = json?["weather"] as? [[String: Any]],
                       let weather = weatherArray.first,
                       let wind = json?["wind"] as? [String: Any] {
                        
                        self.isUsingSimulatedData = false
                        self.temperature = (main["temp"] as? Double) ?? 0
                        self.feelsLike = (main["feels_like"] as? Double) ?? 0
                        self.humidity = (main["humidity"] as? Int) ?? 0
                        self.condition = (weather["main"] as? String) ?? ""
                        self.windSpeed = (wind["speed"] as? Double) ?? 0
                        
                        // Map weather condition to SF Symbol
                        let weatherId = (weather["id"] as? Int) ?? 800
                        self.conditionIcon = self.getWeatherIcon(for: weatherId)
                        
                        print("✅ Successfully parsed weather data: \(self.condition), \(self.temperature)°F")
                    } else {
                        print("⚠️ Weather API: Invalid data format - couldn't extract main, weather, or wind")
                        self.fallbackToSimulatedWeather(error: "Invalid weather data format")
                    }
                } catch {
                    print("⚠️ Weather API JSON parsing error: \(error.localizedDescription)")
                    self.fallbackToSimulatedWeather(error: "JSON parsing error: \(error.localizedDescription)")
                }
            }
        }
        
        task.resume()
    }
    
    // Fallback to simulated data with an error message
    private func fallbackToSimulatedWeather(error: String) {
        errorMessage = error
        print("⚠️ Weather API error. Falling back to simulated data.")
        
        // Only simulate if we're not already using simulated data
        if !isUsingSimulatedData {
            simulateWeather()
        }
    }
    
    // Simulate weather data for demo purposes
    private func simulateWeather() {
        isUsingSimulatedData = true
        
        // Simulate network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            
            // Generate random weather based on season
            let calendar = Calendar.current
            let month = calendar.component(.month, from: Date())
            
            // Summer-like weather (warm)
            if month >= 5 && month <= 9 {
                self.temperature = Double.random(in: 70...90)
                self.feelsLike = self.temperature + Double.random(in: -3...5)
                self.humidity = Int.random(in: 40...80)
                self.windSpeed = Double.random(in: 3...12)
                
                // Random condition
                let conditions = [
                    ("Clear", "sun.max"),
                    ("Partly Cloudy", "cloud.sun"),
                    ("Cloudy", "cloud"),
                    ("Light Rain", "cloud.drizzle")
                ]
                let randomCondition = conditions.randomElement()!
                self.condition = randomCondition.0
                self.conditionIcon = randomCondition.1
            } 
            // Winter-like weather (cold)
            else {
                self.temperature = Double.random(in: 30...55)
                self.feelsLike = self.temperature - Double.random(in: 0...10)
                self.humidity = Int.random(in: 50...90)
                self.windSpeed = Double.random(in: 5...15)
                
                // Random condition
                let conditions = [
                    ("Cloudy", "cloud"),
                    ("Partly Cloudy", "cloud.sun"),
                    ("Rain", "cloud.rain"),
                    ("Snow", "cloud.snow")
                ]
                let randomCondition = conditions.randomElement()!
                self.condition = randomCondition.0
                self.conditionIcon = randomCondition.1
            }
            
            self.isLoading = false
            print("🤖 Using simulated weather data: \(self.condition), \(self.temperature)°F")
        }
    }
    
    // Convert weather condition code to SF Symbol name
    private func getWeatherIcon(for conditionId: Int) -> String {
        switch conditionId {
        case 200...232: // Thunderstorm
            return "cloud.bolt.rain"
        case 300...321: // Drizzle
            return "cloud.drizzle"
        case 500...531: // Rain
            return "cloud.rain"
        case 600...622: // Snow
            return "cloud.snow"
        case 701...781: // Atmosphere (fog, mist, etc.)
            return "cloud.fog"
        case 800: // Clear
            return "sun.max"
        case 801: // Few clouds
            return "cloud.sun"
        case 802...804: // Clouds
            return "cloud"
        default:
            return "cloud"
        }
    }
} 