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
    
    private let apiKey = "demo_key" // Replace with your OpenWeatherMap API key
    
    func fetchWeather(for location: CLLocation) {
        isLoading = true
        errorMessage = nil
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        // For demo purposes, simulate weather data rather than making actual API calls
        simulateWeatherData()
        
        // In a real app, you would make an API call:
        /*
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&units=imperial&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            self.isLoading = false
            self.errorMessage = "Invalid URL"
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    self.errorMessage = "No data received"
                    return
                }
                
                do {
                    // Parse JSON response
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let main = json["main"] as? [String: Any],
                       let weather = (json["weather"] as? [[String: Any]])?.first,
                       let wind = json["wind"] as? [String: Any] {
                        
                        self.temperature = (main["temp"] as? Double) ?? 0
                        self.feelsLike = (main["feels_like"] as? Double) ?? 0
                        self.humidity = (main["humidity"] as? Int) ?? 0
                        self.condition = (weather["main"] as? String) ?? ""
                        self.windSpeed = (wind["speed"] as? Double) ?? 0
                        
                        // Map weather condition to SF Symbol
                        let weatherId = (weather["id"] as? Int) ?? 800
                        self.conditionIcon = self.getWeatherIcon(for: weatherId)
                    } else {
                        self.errorMessage = "Invalid weather data format"
                    }
                } catch {
                    self.errorMessage = "JSON parsing error: \(error.localizedDescription)"
                }
            }
        }
        
        task.resume()
        */
    }
    
    // Simulate weather data for demo purposes
    private func simulateWeatherData() {
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