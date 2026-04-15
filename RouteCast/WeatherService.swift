//
//  WeatherService.swift
//  RouteCast
//
//  Created by Caio Albuquerque on 4/11/26.

import SwiftUI
import Foundation
import CoreLocation

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

// MARK: - Weather Type

enum WeatherType {
    case hourly, current, defaults
}

// MARK: - Weather Error

enum WeatherError: Error {
    case httpError(statusCode: Int)
    case invalidResponse
}

// MARK: - Models

struct WeatherData: Codable {
    let latitude: Double
    let longitude: Double
    let current: CurrentWeather?
    let hourly: HourlyWeather?
}

struct CurrentWeather: Codable {
    let time: String
    let temperature2m: Double
    let windSpeed10m: Double
    let cloudCover: Double
    let precipitationProbability: Double
    let precipitation: Double

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m            = "temperature_2m"
        case windSpeed10m             = "wind_speed_10m"
        case cloudCover               = "cloud_cover"
        case precipitationProbability = "precipitation_probability"
        case precipitation
    }
}

struct HourlyWeather: Codable {
    let time: [String]
    let temperature2m: [Double]
    let windSpeed10m: [Double]
    let cloudCover: [Int]
    let precipitationProbability: [Int]
    let precipitation: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m            = "temperature_2m"
        case windSpeed10m             = "wind_speed_10m"
        case cloudCover               = "cloud_cover"
        case precipitationProbability = "precipitation_probability"
        case precipitation
    }
}

// MARK: - Provider

struct WeatherProvider {

    private static func getWeatherHorizon(type: WeatherType = .defaults) -> String {
        let params = "temperature_2m,wind_speed_10m,cloud_cover,precipitation_probability,precipitation"

        switch type {
        case .current: return "current=\(params)&timezone=auto"
        case .hourly:  return "hourly=\(params)&timezone=auto"
        default:       return "current=\(params)&hourly=\(params)&timezone=auto"
        }
    }

    static func getWeather(location: CLLocationCoordinate2D, type: WeatherType = .defaults) async throws -> WeatherData? {
        let urlSession = URLSession.shared

        let horizon = getWeatherHorizon(type: type)

        let urlString = "https://api.open-meteo.com/v1/forecast?latitude=\(location.latitude)&longitude=\(location.longitude)&\(horizon)"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        let urlRequest = URLRequest(url: url)

        let (data, response) = try await urlSession.data(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw WeatherError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw WeatherError.httpError(statusCode: httpResponse.statusCode)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(WeatherData.self, from: data)
    }

}
