//
//  HourlyView.swift
//  RouteCast
//
//  Created by Caio Albuquerque on 4/11/26.
//

import SwiftUI
import CoreLocation

// Temperature Graph

/// Draws a dot-and-line temperature trend graph aligned with hourly columns.
private struct TempGraphView: View {
    let hourlyData: [HourlyWeather]

    private let itemWidth:   CGFloat = 72
    private let graphHeight: CGFloat = 56
    private let dotRadius:   CGFloat = 5

    private var temps: [Double] { hourlyData.map(\.temperature) }
    private var minTemp: Double { (temps.min() ?? 0)   - 3 }
    private var maxTemp: Double { (temps.max() ?? 100) + 3 }
    private var tempRange: Double { max(maxTemp - minTemp, 1) }

    private func point(at index: Int, in size: CGSize) -> CGPoint {
        let x = itemWidth * CGFloat(index) + itemWidth / 2
        let normalized = (hourlyData[index].temperature - minTemp) / tempRange
        let y = size.height - normalized * (size.height - dotRadius * 2) - dotRadius
        return CGPoint(x: x, y: y)
    }

    var body: some View {
        Canvas { context, size in
            // Connecting line
            var linePath = Path()
            for i in hourlyData.indices {
                let p = point(at: i, in: size)
                i == 0 ? linePath.move(to: p) : linePath.addLine(to: p)
            }
            context.stroke(
                linePath,
                with: .color(RouteCastColors.goldenAmber),
                style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round)
            )

            // Dots
            for i in hourlyData.indices {
                let p = point(at: i, in: size)
                let rect = CGRect(
                    x: p.x - dotRadius, y: p.y - dotRadius,
                    width: dotRadius * 2, height: dotRadius * 2
                )
                context.fill(Path(ellipseIn: rect), with: .color(RouteCastColors.goldenAmber))
                context.stroke(Path(ellipseIn: rect), with: .color(.white), lineWidth: 1.5)
            }
        }
        .frame(width: itemWidth * CGFloat(hourlyData.count), height: graphHeight)
    }
}

// Hourly Scroll Box

/// Horizontally scrollable card: time labels, weather icons, temperature graph.
struct HourlyScrollBox: View {
    let hourlyData: [HourlyWeather]
    private let itemWidth: CGFloat = 72

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 0) {
                    ForEach(hourlyData) { item in
                        VStack(spacing: 6) {
                            Text(item.time)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(RouteCastColors.steeringGray)
                            Image(systemName: item.condition.sfSymbol)
                                .font(.system(size: 26))
                                .foregroundStyle(item.condition.color)
                            Text("\(Int(item.temperature))°F")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(RouteCastColors.steeringGray)
                        }
                        .frame(width: itemWidth)
                    }
                }
                TempGraphView(hourlyData: hourlyData)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 8)
        }
        .background(RouteCastColors.boxBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(RouteCastColors.goldenAmber.opacity(0.4), lineWidth: 1)
        )
    }
}

// City Forecast Card (used in route view)

/// Compact weather card for a single city along a route.
private struct CityForecastCard: View {
    let forecast: CityForecast

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // City name + icon
            HStack {
                Text(forecast.cityName)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(RouteCastColors.steeringGray)
                Spacer()
                Image(systemName: forecast.weather.condition.sfSymbol)
                    .font(.system(size: 36))
                    .foregroundStyle(forecast.weather.condition.color)
            }

            // Description
            Text(forecast.weather.description)
                .font(.subheadline)
                .foregroundColor(RouteCastColors.steeringGray.opacity(0.8))

            // Mini hourly scroll
            HourlyScrollBox(hourlyData: forecast.hourly)
        }
        .padding()
        .background(RouteCastColors.boxBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(RouteCastColors.goldenAmber.opacity(0.4), lineWidth: 1)
        )
    }
}

// HourlyView

struct HourlyView: View {
    @Environment(RouteStore.self) private var routeStore
    let locationManager: LocationManager

    @State private var cityName       = "Loading..."
    @State private var currentWeather = CurrentWeather(description: "Loading...", condition: .cloudy, temperature: "--")
    @State private var hourlyForecast: [HourlyWeather] = []
    @State private var hasLoaded      = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if routeStore.cityForecasts.isEmpty {
                    currentLocationView
                } else {
                    routeView
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(RouteCastColors.pageBackground.ignoresSafeArea())
        .onAppear { loadWeather() }
        .onChange(of: locationManager.location) { _, newLocation in
            guard newLocation != nil, !hasLoaded else { return }
            loadWeather()
        }
        .onChange(of: routeStore.cityForecasts.isEmpty) { wasEmpty, isNowEmpty in
            // Fires when a city is selected from RouteView or the route is cleared.
            // Reset so loadWeather() picks up the newly set location.
            if !wasEmpty && isNowEmpty {
                hasLoaded = false
                loadWeather()
            }
        }
    }

    // Current Location View

    private var currentLocationView: some View {
        VStack(spacing: 28) {
            Text(cityName.uppercased())
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(RouteCastColors.steeringGray)
                .padding(.top, 8)

            HStack(spacing: 16) {
                Image(systemName: currentWeather.condition.sfSymbol)
                    .font(.system(size: 90))
                    .foregroundStyle(currentWeather.condition.color)
                    .shadow(color: RouteCastColors.goldenAmber.opacity(0.35), radius: 10, y: 4)
                Text(currentWeather.temperature)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(RouteCastColors.steeringGray)
                    .shadow(color: RouteCastColors.goldenAmber.opacity(0.15), radius: 2, y: 1)
            }

            VStack(spacing: 10) {
                Text("Current Weather")
                    .font(.title3).fontWeight(.semibold)
                    .foregroundColor(RouteCastColors.steeringGray)

                Text(currentWeather.description)
                    .font(.body)
                    .foregroundColor(RouteCastColors.steeringGray.opacity(0.85))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(RouteCastColors.boxBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(RouteCastColors.goldenAmber.opacity(0.4), lineWidth: 1)
                    )
            }

            VStack(spacing: 10) {
                Text("Hourly Weather")
                    .font(.title3).fontWeight(.semibold)
                    .foregroundColor(RouteCastColors.steeringGray)

                HourlyScrollBox(hourlyData: hourlyForecast)
            }
        }
    }

    // Route View

    private var routeView: some View {
        VStack(spacing: 16) {
            // Route label + clear button
            HStack {
                Text(routeStore.routeLabel)
                    .font(.headline)
                    .foregroundColor(RouteCastColors.steeringGray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Spacer()
                Button("Clear") {
                    routeStore.clearRoute()
                    hasLoaded = false
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(RouteCastColors.goldenAmber)
            }
            .padding(.top, 8)

            if routeStore.isLoading {
                ProgressView("Loading weather along route…")
                    .padding(.top, 40)
            } else if let error = routeStore.errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
            } else {
                ForEach(routeStore.cityForecasts) { forecast in
                    CityForecastCard(forecast: forecast)
                        .onTapGesture {
                            let newLocation = CLLocation(
                                latitude: forecast.coordinate.latitude,
                                longitude: forecast.coordinate.longitude
                            )
                            locationManager.setLocation(newLocation)
                            cityName = forecast.cityName
                            currentWeather = forecast.weather
                            hourlyForecast = forecast.hourly
                            routeStore.clearRoute()
                        }
                }
            }
        }
    }

    // Helpers

    private func loadWeather() {
        guard let location = locationManager.location, !hasLoaded else { return }
        hasLoaded = true

        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude

        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            DispatchQueue.main.async {
                cityName = placemarks?.first?.locality ?? "Unknown"
            }
        }

        Task {
            let current = await WeatherDataProvider.fetchCurrentAsync(lat: lat, lon: lon)
            let hourly = await WeatherDataProvider.fetchHourlyAsync(lat: lat, lon: lon)

            await MainActor.run {
                currentWeather = current
                hourlyForecast = hourly
            }
        }
    }
}

#Preview {
    HourlyView(locationManager: LocationManager())
        .environment(RouteStore())
}
