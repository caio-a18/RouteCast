//
//  RouteStore.swift
//  RouteCast
//
//  Created by Caio Albuquerque on 4/13/26.
//

import Foundation
import MapKit
import CoreLocation
import Observation

// MARK: - City Forecast Model

struct CityForecast: Identifiable {
    let id          = UUID()
    let cityName    : String
    let coordinate  : CLLocationCoordinate2D
    let weather     : CurrentWeather
    let hourly      : [HourlyWeather]
}

// MARK: - RouteStore
//
// ═══════════════════════════════════════════════════════════════════════
//  HOW TO USE THIS FROM ROUTEVIEW
// ═══════════════════════════════════════════════════════════════════════
//
//  1. Grab the store from the environment:
//
//       @EnvironmentObject var routeStore: RouteStore
//
//  2. When the user submits a route, call loadRoute():
//
//       Button("Get Weather Along Route") {
//           Task {
//               await routeStore.loadRoute(from: "Los Angeles, CA",
//                                           to: "Seattle, WA")
//           }
//       }
//
//
//  3. To clear the route and return to current-location view:
//
//       Button("Clear") { routeStore.clearRoute() }
//
// ═══════════════════════════════════════════════════════════════════════

@Observable
class RouteStore {
    var cityForecasts : [CityForecast] = []
    var isLoading     : Bool           = false
    var routeLabel    : String         = ""
    var errorMessage  : String?        = nil

    // Public API

    func loadRoute(from origin: String, to destination: String) async {
        isLoading    = true
        errorMessage = nil
        routeLabel   = "\(origin) → \(destination)"
        cityForecasts = []

        do {
            let stops = try await citiesAlongRoute(from: origin, to: destination)
            
            var forecasts: [CityForecast] = []
            for stop in stops {
                let weather = await WeatherDataProvider.fetchCurrentAsync(lat: stop.coordinate.latitude,
                                                                          lon: stop.coordinate.longitude)
                let hourly = await WeatherDataProvider.fetchHourlyAsync(lat: stop.coordinate.latitude,
                                                                        lon: stop.coordinate.longitude)
                forecasts.append(CityForecast(
                    cityName   : stop.name,
                    coordinate : stop.coordinate,
                    weather    : weather,
                    hourly     : hourly
                ))
            }
            
            await MainActor.run {
                self.cityForecasts = forecasts
            }
        } catch {
            errorMessage  = error.localizedDescription
            cityForecasts = []
        }

        isLoading = false
    }

    func clearRoute() {
        cityForecasts = []
        routeLabel    = ""
        errorMessage  = nil
    }

    // Route logic

    private struct Stop {
        let name       : String
        let coordinate : CLLocationCoordinate2D
    }

    private func citiesAlongRoute(from origin: String, to destination: String) async throws -> [Stop] {
        let geocoder = CLGeocoder()

        // Forward-geocode start and end
        guard let originCoord = try await geocoder.geocodeAddressString(origin).first?.location?.coordinate,
              let destCoord   = try await geocoder.geocodeAddressString(destination).first?.location?.coordinate
        else { throw RouteError.geocodeFailed }

        // Get driving route via MapKit
        let request        = MKDirections.Request()
        request.source      = MKMapItem(placemark: MKPlacemark(coordinate: originCoord))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destCoord))
        request.transportType = .automobile

        let response = try await withCheckedThrowingContinuation { (cont: CheckedContinuation<MKDirections.Response, Error>) in
            MKDirections(request: request).calculate { result, error in
                if let error  { cont.resume(throwing: error)     }
                else if let r = result { cont.resume(returning: r) }
                else { cont.resume(throwing: RouteError.noRouteFound) }
            }
        }

        guard let route = response.routes.first else { throw RouteError.noRouteFound }

        // Sample evenly-spaced points along the polyline
        let samples = samplePolyline(route.polyline,
                                     count: sampleCount(for: route.distance))

        // Reverse-geocode each sample; deduplicate by city name
        var stops       : [Stop]   = []
        var seenCities  : Set<String> = []

        for coord in samples {
            let placemarks = try? await geocoder.reverseGeocodeLocation(
                CLLocation(latitude: coord.latitude, longitude: coord.longitude)
            )
            let city = placemarks?.first?.locality
                    ?? placemarks?.first?.administrativeArea
                    ?? "Unknown"

            if !seenCities.contains(city) {
                seenCities.insert(city)
                stops.append(Stop(name: city, coordinate: coord))
            }
        }

        return stops
    }

    /// How many sample points to pull from the polyline based on route length.
    private func sampleCount(for meters: CLLocationDistance) -> Int {
        let miles = meters / 1609.34
        switch miles {
        case ..<150: return 3
        case ..<400: return 5
        case ..<800: return 7
        default:     return 9
        }
    }

    /// Returns count evenly spaced coordinates from a polyline (always includes start & end)
    private func samplePolyline(_ polyline: MKPolyline, count: Int) -> [CLLocationCoordinate2D] {
        let n      = polyline.pointCount
        let pts    = polyline.points()
        guard n > 0, count > 0 else { return [] }
        return (0..<count).map { i in
            let idx = i == count - 1 ? n - 1 : (i * n) / count
            return pts[idx].coordinate
        }
    }

    // Errors

    enum RouteError: LocalizedError {
        case geocodeFailed
        case noRouteFound

        var errorDescription: String? {
            switch self {
            case .geocodeFailed : return "Couldn't find one of the locations. Try adding a location."
            case .noRouteFound  : return "No driving route found between those locations."
            }
        }
    }
}
