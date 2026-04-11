//
//  HourlyView.swift
//  RouteCast
//
//  Created by Caio Albuquerque on 4/11/26.
//

import SwiftUI
import CoreLocation

// MARK: - Temperature Graph

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

    /// Maps a data-index + canvas size to a CGPoint in canvas coordinates.
    private func point(at index: Int, in size: CGSize) -> CGPoint {
        let x = itemWidth * CGFloat(index) + itemWidth / 2
        let normalized = (hourlyData[index].temperature - minTemp) / tempRange
        let y = size.height - normalized * (size.height - dotRadius * 2) - dotRadius
        return CGPoint(x: x, y: y)
    }

    var body: some View {
        Canvas { context, size in
            // ── Connecting line ──────────────────────────────────────────────
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

            // ── Dots ─────────────────────────────────────────────────────────
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

// MARK: - Hourly Scroll Box

/// Horizontally scrollable card showing time labels, weather icons, and a
/// temperature trend graph for each forecasted hour.
private struct HourlyScrollBox: View {
    let hourlyData: [HourlyWeather]
    private let itemWidth: CGFloat = 72

    var body: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            VStack(alignment: .leading, spacing: 10) {

                // Time + icon columns
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
                        }
                        .frame(width: itemWidth)
                    }
                }

                // Temperature trend line
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

// MARK: - HourlyView

struct HourlyView: View {
    @StateObject private var locationManager = LocationManager()

    @State private var cityName      = "Loading..."
    @State private var currentWeather = WeatherDataProvider.fetchCurrent(lat: 0, lon: 0)
    @State private var hourlyForecast = WeatherDataProvider.fetchHourly(lat: 0, lon: 0)

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {

                // LOCATION header
                Text(cityName.uppercased())
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(RouteCastColors.steeringGray)
                    .padding(.top, 8)

                // Large weather icon
                Image(systemName: currentWeather.condition.sfSymbol)
                    .font(.system(size: 90))
                    .foregroundStyle(currentWeather.condition.color)
                    .shadow(color: RouteCastColors.goldenAmber.opacity(0.35), radius: 10, y: 4)

                // Current Weather card
                VStack(spacing: 10) {
                    Text("Current Weather")
                        .font(.title3)
                        .fontWeight(.semibold)
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

                // Hourly Weather card
                VStack(spacing: 10) {
                    Text("Hourly Weather")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(RouteCastColors.steeringGray)

                    HourlyScrollBox(hourlyData: hourlyForecast)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(RouteCastColors.pageBackground.ignoresSafeArea())
        .onAppear { loadWeather() }
        .onChange(of: locationManager.location) { _, newLocation in
            guard newLocation != nil else { return }
            loadWeather()
        }
    }

    // MARK: - Helpers

    private func loadWeather() {
        guard let location = locationManager.location else { return }
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude

        // Reverse-geocode the location for the city name
        CLGeocoder().reverseGeocodeLocation(location) { placemarks, _ in
            DispatchQueue.main.async {
                cityName = placemarks?.first?.locality ?? "Unknown"
            }
        }

        // Fetch weather data (swap for async API calls when you have a key)
        currentWeather = WeatherDataProvider.fetchCurrent(lat: lat, lon: lon)
        hourlyForecast = WeatherDataProvider.fetchHourly(lat: lat, lon: lon)
    }
}

#Preview {
    HourlyView()
}
