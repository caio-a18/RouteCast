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

    // private static let apiKey = APIKeys.openWeatherMap

    /// Returns current weather for the given coordinates
    static func fetchCurrent(lat: Double, lon: Double) -> CurrentWeather {
        return mockCurrent
    }

    /// Returns hourly forecast for the given coordinates
    /// The One Call API response includes a hourly array
    static func fetchHourly(lat: Double, lon: Double) -> [HourlyWeather] {
        return mockHourly
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
