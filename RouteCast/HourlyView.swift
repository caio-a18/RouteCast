//
//  HourlyView.swift
//  RouteCast
//
//  Created by Caio Albuquerque on 4/11/26.
//

import SwiftUI
import CoreLocation

// MARK: - Temperature Graph

private struct TempGraphView: View {
    let hourlyData: [HourlyWeather]

    private let itemWidth:   CGFloat = 80
    private let graphHeight: CGFloat = 64
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
            // Gradient area fill under the line
            var areaPath = Path()
            for i in hourlyData.indices {
                let p = point(at: i, in: size)
                if i == 0 {
                    areaPath.move(to: CGPoint(x: p.x, y: size.height))
                    areaPath.addLine(to: p)
                } else {
                    areaPath.addLine(to: p)
                }
            }
            if let last = hourlyData.indices.last {
                areaPath.addLine(to: CGPoint(x: point(at: last, in: size).x, y: size.height))
            }
            areaPath.closeSubpath()
            context.fill(
                areaPath,
                with: .linearGradient(
                    Gradient(colors: [
                        RouteCastColors.goldenAmber.opacity(0.28),
                        RouteCastColors.goldenAmber.opacity(0)
                    ]),
                    startPoint: CGPoint(x: size.width / 2, y: 0),
                    endPoint: CGPoint(x: size.width / 2, y: size.height)
                )
            )

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

// MARK: - Hourly Scroll Box

struct HourlyScrollBox: View {
    let hourlyData: [HourlyWeather]
    private let itemWidth: CGFloat = 80

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 0) {
                    ForEach(hourlyData) { item in
                        VStack(spacing: 6) {
                            Text(item.time)
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(RouteCastColors.steeringGray.opacity(0.55))
                            Image(systemName: item.condition.sfSymbol)
                                .font(.system(size: 24))
                                .foregroundStyle(item.condition.color)
                            Text("\(Int(item.temperature))°")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(RouteCastColors.steeringGray)
                        }
                        .frame(width: itemWidth)
                    }
                }
                TempGraphView(hourlyData: hourlyData)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 12)
        }
        .background(RouteCastColors.boxBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }
}

// MARK: - City Forecast Card

private struct CityForecastCard: View {
    let forecast: CityForecast
    let isOrigin: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(forecast.cityName)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(RouteCastColors.steeringGray)
                    Text("\(isOrigin ? "Departure" : "Est. arrival") \(forecast.arrivalTime.formatted(date: .omitted, time: .shortened))")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(RouteCastColors.goldenAmber)
                        .clipShape(Capsule())
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: forecast.weather.condition.sfSymbol)
                        .font(.system(size: 32))
                        .foregroundStyle(forecast.weather.condition.color)
                    Text(forecast.weather.temperature)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(RouteCastColors.steeringGray)
                }
            }

            Text(forecast.weather.description)
                .font(.subheadline)
                .foregroundStyle(RouteCastColors.steeringGray.opacity(0.65))

            HStack(spacing: 0) {
                ForEach(Array(forecast.hourly.prefix(5))) { item in
                    VStack(spacing: 6) {
                        Text(item.time)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(RouteCastColors.steeringGray.opacity(0.55))
                        Image(systemName: item.condition.sfSymbol)
                            .font(.system(size: 22))
                            .foregroundStyle(item.condition.color)
                        Text("\(Int(item.temperature))°")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(RouteCastColors.steeringGray)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(16)
        .background(RouteCastColors.boxBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 4)
    }
}

// MARK: - HourlyView

struct HourlyView: View {
    @Environment(RouteStore.self) private var routeStore
    let locationManager: LocationManager

    @State private var cityName       = "Loading..."
    @State private var currentWeather = CurrentWeather(description: "Loading...", condition: .cloudy, temperature: "--")
    @State private var hourlyForecast: [HourlyWeather] = []
    @State private var hasLoaded      = false
    @State private var selectedCity: CityForecast? = nil

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if let city = selectedCity {
                    selectedCityView(city)
                } else if routeStore.cityForecasts.isEmpty {
                    currentLocationView
                } else {
                    routeView
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)
            .padding(.bottom, 110)
        }
        .background(RouteCastColors.pageBackground.ignoresSafeArea())
        .onAppear { loadWeather() }
        .onChange(of: locationManager.location) { _, newLocation in
            guard newLocation != nil, !hasLoaded else { return }
            loadWeather()
        }
        .onChange(of: routeStore.cityForecasts.isEmpty) { _, isNowEmpty in
            if isNowEmpty { selectedCity = nil }
        }
    }

    // MARK: - Current Location View

    private var currentLocationView: some View {
        VStack(spacing: 20) {
            heroCard(cityName: cityName, weather: currentWeather, subtitle: nil)
            sectionHeader("Hourly Forecast")
            HourlyScrollBox(hourlyData: hourlyForecast)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }

    // MARK: - Selected City View

    private func selectedCityView(_ city: CityForecast) -> some View {
        VStack(spacing: 20) {
            HStack {
                Button {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        selectedCity = nil
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Route")
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(RouteCastColors.goldenAmber)
                }
                Spacer()
            }
            .padding(.top, 4)

            heroCard(
                cityName: city.cityName,
                weather: city.weather,
                subtitle: "\(city.id == routeStore.cityForecasts.first?.id ? "Departure" : "Est. arrival") \(city.arrivalTime.formatted(date: .omitted, time: .shortened))"
            )
            sectionHeader("Hourly Forecast")
            HourlyScrollBox(hourlyData: city.hourly)
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .trailing).combined(with: .opacity)
        ))
    }

    // MARK: - Route View

    private var routeView: some View {
        VStack(spacing: 16) {
            routeHeader
            if routeStore.isLoading {
                ProgressView("Loading weather along route…")
                    .padding(.top, 40)
            } else if let error = routeStore.errorMessage {
                Text(error)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 40)
            } else {
                ForEach(Array(routeStore.cityForecasts.enumerated()), id: \.element.id) { index, forecast in
                    CityForecastCard(forecast: forecast, isOrigin: index == 0)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                selectedCity = forecast
                            }
                        }
                }
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.98)))
    }

    // MARK: - Shared Components

    private func pageTitle(_ title: String) -> some View {
        Text(title)
            .font(.largeTitle.weight(.bold))
            .foregroundStyle(RouteCastColors.steeringGray)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func heroCard(cityName: String, weather: CurrentWeather, subtitle: String?) -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text(cityName.uppercased())
                    .font(.caption.weight(.bold))
                    .tracking(2.5)
                    .foregroundStyle(RouteCastColors.steeringGray.opacity(0.45))
                if let subtitle {
                    Text(subtitle)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(RouteCastColors.goldenAmber)
                        .clipShape(Capsule())
                }
            }
            .padding(.top, 28)

            Image(systemName: weather.condition.sfSymbol)
                .font(.system(size: 100))
                .foregroundStyle(weather.condition.color)
                .shadow(color: weather.condition.color.opacity(0.3), radius: 18, y: 8)
                .padding(.top, 20)
                .padding(.bottom, 6)

            Text(weather.temperature)
                .font(.system(size: 76, weight: .bold, design: .rounded))
                .foregroundStyle(RouteCastColors.steeringGray)

            Text(weather.description)
                .font(.subheadline)
                .foregroundStyle(RouteCastColors.steeringGray.opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .padding(.top, 6)
                .padding(.bottom, 32)
        }
        .frame(maxWidth: .infinity)
        .background(RouteCastColors.boxBackground)
        .clipShape(RoundedRectangle(cornerRadius: 26))
        .shadow(color: .black.opacity(0.08), radius: 18, x: 0, y: 6)
    }

    private func sectionHeader(_ title: String) -> some View {
        HStack(spacing: 10) {
            Text(title.uppercased())
                .font(.caption.weight(.semibold))
                .tracking(1.5)
                .foregroundStyle(RouteCastColors.steeringGray.opacity(0.4))
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(RouteCastColors.steeringGray.opacity(0.1))
        }
    }

    private var routeHeader: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 3) {
                Text("ROUTE")
                    .font(.caption.weight(.bold))
                    .tracking(1.5)
                    .foregroundStyle(RouteCastColors.steeringGray.opacity(0.4))
                Text(routeStore.routeLabel)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(RouteCastColors.steeringGray)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            Spacer()
            Button {
                routeStore.clearRoute()
                hasLoaded = false
            } label: {
                Text("Clear")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(RouteCastColors.steeringGray.opacity(0.55))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(RouteCastColors.steeringGray.opacity(0.08))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(RouteCastColors.boxBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
        .padding(.top, 4)
    }

    // MARK: - Helpers

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
            let hourly  = await WeatherDataProvider.fetchHourlyAsync(lat: lat, lon: lon)

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
