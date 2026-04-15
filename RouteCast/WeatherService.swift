//
//  WeatherService.swift
//  RouteCast
//
//  Created by Caio Albuquerque on 4/11/26.

import SwiftUI
import Foundation

// MARK: - Weather Condition

enum WeatherCondition {
    case sunny, partlyCloudy, cloudy, rainy, stormy, snowy

    /// SF Symbol name for this condition
    var sfSymbol: String {
        switch self {
        case .sunny:        return "sun.max.fill"
        case .partlyCloudy: return "cloud.sun.fill"
        case .cloudy:       return "cloud.fill"
        case .rainy:        return "cloud.rain.fill"
        case .stormy:       return "cloud.bolt.rain.fill"
        case .snowy:        return "cloud.snow.fill"
        }
    }

    /// Display color for the condition icon
    var color: Color {
        switch self {
        case .sunny:        return RouteCastColors.sunYellow
        case .partlyCloudy: return RouteCastColors.goldenAmber
        case .cloudy:       return .gray
        case .rainy:        return .blue.opacity(0.8)
        case .stormy:       return .indigo
        case .snowy:        return .cyan
        }
    }
}

// MARK: - Data Models

struct CurrentWeather {
    let description: String
    let condition: WeatherCondition
    let temperature: String 
}

struct HourlyWeather: Identifiable {
    let id = UUID()
    let time: String         
    let condition: WeatherCondition
    let temperature: Double
}

// MARK: - Data Provider

enum WeatherDataProvider {

    private static let apiKey = APIKeys.openWeatherMap

    /// Returns current weather for the given coordinates (synchronous, blocking call)
    static func fetchCurrent(lat: Double, lon: Double) -> CurrentWeather {
        var result = mockCurrent
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            result = await fetchCurrentAsync(lat: lat, lon: lon)
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }

    /// Returns hourly forecast for the given coordinates (synchronous, blocking call)
    static func fetchHourly(lat: Double, lon: Double) -> [HourlyWeather] {
        var result = mockHourly
        let semaphore = DispatchSemaphore(value: 0)
        
        Task {
            result = await fetchHourlyAsync(lat: lat, lon: lon)
            semaphore.signal()
        }
        
        semaphore.wait()
        return result
    }

    /// Async version: fetch current weather for the given coordinates
    static func fetchCurrentAsync(lat: Double, lon: Double) async -> CurrentWeather {
        let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=imperial"
        
        guard let url = URL(string: urlString) else { return mockCurrent }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(OpenWeatherResponse.self, from: data)
            
            let condition = mapWeatherCondition(response.weather.first?.main ?? "")
            let description = response.weather.first?.description ?? "No description"
            let temperature = "\(Int(response.main.temp))°F"
            
            return CurrentWeather(
                description: description.capitalized,
                condition: condition,
                temperature: temperature
            )
        } catch {
            return mockCurrent
        }
    }

    /// Async version: fetch hourly forecast for the given coordinates
    static func fetchHourlyAsync(lat: Double, lon: Double) async -> [HourlyWeather] {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=imperial"

        guard let url = URL(string: urlString) else { return mockHourly }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(ForecastResponse.self, from: data)

            var hourlyData: [HourlyWeather] = []
            let calendar = Calendar.current

            for item in response.list.prefix(12) {
                let timestamp = Date(timeIntervalSince1970: Double(item.dt))
                let components = calendar.dateComponents([.hour], from: timestamp)
                let rawHour = components.hour ?? 0
                let hour12 = rawHour % 12
                let ampm = rawHour < 12 ? "am" : "pm"
                let timeString = "\(hour12 == 0 ? 12 : hour12)\(ampm)"

                let condition = mapWeatherCondition(item.weather.first?.main ?? "")

                hourlyData.append(HourlyWeather(
                    time: timeString,
                    condition: condition,
                    temperature: item.main.temp
                ))
            }

            return hourlyData.isEmpty ? mockHourly : hourlyData
        } catch {
            return mockHourly
        }
    }

    /// Maps OpenWeatherMap condition strings to our WeatherCondition enum
    private static func mapWeatherCondition(_ main: String) -> WeatherCondition {
        let condition = main.lowercased()
        switch condition {
        case "clear":
            return .sunny
        case "clouds":
            return .cloudy
        case "partly cloudy", "partly_cloudy":
            return .partlyCloudy
        case "rain", "drizzle":
            return .rainy
        case "thunderstorm":
            return .stormy
        case "snow":
            return .snowy
        default:
            return .cloudy
        }
    }

    // MARK: - OpenWeatherMap API Models

    private struct OpenWeatherResponse: Codable {
        let main: MainData
        let weather: [WeatherData]
    }

    private struct MainData: Codable {
        let temp: Double
    }

    private struct WeatherData: Codable {
        let main: String
        let description: String
    }

    private struct ForecastResponse: Codable {
        let list: [ForecastItem]
    }

    private struct ForecastItem: Codable {
        let dt: Int
        let main: ForecastMain
        let weather: [WeatherData]
    }

    private struct ForecastMain: Codable {
        let temp: Double
    }

    // MARK: Mock data

    private static let mockCurrent = CurrentWeather(
        description: "Clear skies with a light breeze. Great conditions for driving.",
        condition: .sunny,
        temperature: "72°F"
    )

    private static let mockHourly: [HourlyWeather] = [
        HourlyWeather(time: "7am",  condition: .sunny,        temperature: 65),
        HourlyWeather(time: "8am",  condition: .sunny,        temperature: 68),
        HourlyWeather(time: "9am",  condition: .partlyCloudy, temperature: 70),
        HourlyWeather(time: "10am", condition: .cloudy,       temperature: 72),
        HourlyWeather(time: "11am", condition: .cloudy,       temperature: 71),
        HourlyWeather(time: "12pm", condition: .partlyCloudy, temperature: 74),
        HourlyWeather(time: "1pm",  condition: .sunny,        temperature: 76),
    ]
}
