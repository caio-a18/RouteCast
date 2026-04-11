//
//  WeatherService.swift
//  RouteCast
//
//  Created by Caio Albuquerque on 4/11/26.
//
//  Currently returns mock data.
//
//  HOW TO WIRE UP REAL DATA (OpenWeatherMap):
//  ─────────────────────────────────────────
//  1. Create a free account at https://openweathermap.org
//  2. Go to API Keys and copy your default key (or generate a new one).
//  3. Subscribe to "One Call API 3.0" (free tier: 1,000 calls/day).
//  4. Paste your key in WeatherDataProvider.apiKey below.
//  5. Uncomment the URLSession block in fetchCurrent() / fetchHourly().
//
//  Endpoint used:
//    GET https://api.openweathermap.org/data/3.0/onecall
//        ?lat={lat}&lon={lon}&units=imperial
//        &exclude=minutely,daily,alerts
//        &appid={API_KEY}
//  ─────────────────────────────────────────

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
    let temperature: String     // formatted string, e.g. "72°F"
}

struct HourlyWeather: Identifiable {
    let id = UUID()
    let time: String            // display string, e.g. "7am"
    let condition: WeatherCondition
    let temperature: Double     // Fahrenheit
}

// MARK: - Data Provider

enum WeatherDataProvider {

    private static let apiKey = APIKeys.openWeatherMap

    /// Returns current weather for the given coordinates.
    /// Replace the return value with a real URLSession call once you have an API key.
    static func fetchCurrent(lat: Double, lon: Double) -> CurrentWeather {
        // ── Uncomment to use live data ────────────────────────────────────────
        // let urlString = "https://api.openweathermap.org/data/3.0/onecall" +
        //     "?lat=\(lat)&lon=\(lon)&units=imperial" +
        //     "&exclude=minutely,daily,alerts&appid=\(apiKey)"
        // ... URLSession.shared.dataTask / async/await decode here ...
        // ─────────────────────────────────────────────────────────────────────
        return mockCurrent
    }

    /// Returns hourly forecast for the given coordinates.
    /// The One Call API response includes a `hourly` array (48 hours ahead).
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
