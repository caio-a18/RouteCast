//
//  RouteView.swift
//  RouteCast
//
//  Created by Chiebuka Onyejesi on 4/13/26.
//
import SwiftUI
import Foundation
import MapKit

struct RouteView: View {
    @Environment(RouteStore.self) private var routeStore

    @State private var pointA = ""
    @State private var pointB = ""
    @State private var departure = Date()
    @State private var selectedMode: TransportMode = .driving
    @State private var mapPosition: MapCameraPosition = .automatic

    var body: some View {
        VStack(spacing: 12) {
            formSection

            if routeStore.isLoading {
                ProgressView("Loading route weather...")
                    .padding(.top, 30)
                Spacer()
            } else {
                resultSection
            }
        }
        .padding()
        .background(RouteCastColors.pageBackground.ignoresSafeArea())
    }

    private var formSection: some View {
        VStack(spacing: 12) {
            TextField("Point A", text: $pointA)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)

            TextField("Point B", text: $pointB)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)

            HStack(spacing: 10) {
                DatePicker("Departure", selection: $departure, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .frame(maxWidth: .infinity, alignment: .leading)

                Picker("Mode", selection: $selectedMode) {
                    ForEach(TransportMode.allCases) { mode in
                        Text(mode.title).tag(mode)
                    }
                }
                .pickerStyle(.menu)
            }

            Button {
                Task {
                    await routeStore.loadRoute(from: pointA.trimmingCharacters(in: .whitespacesAndNewlines),
                                               to: pointB.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            } label: {
                Text("Get Route Weather")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 11)
            }
            .buttonStyle(.borderedProminent)
            .tint(RouteCastColors.goldenAmber)
            .disabled(pointA.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                      pointB.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                      routeStore.isLoading)
        }
        .padding(14)
        .background(RouteCastColors.boxBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(RouteCastColors.steeringGray.opacity(0.35), lineWidth: 1)
        )
    }

    private var resultSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let error = routeStore.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .padding(.top, 6)
                }

                if !routeStore.cityForecasts.isEmpty {
                    routeMapCard
                }

                if routeStore.cityForecasts.isEmpty, routeStore.errorMessage == nil {
                    Text("Enter two places and tap Get Route Weather.")
                        .foregroundStyle(RouteCastColors.steeringGray.opacity(0.8))
                        .padding(.top, 6)
                }

                ForEach(routeStore.cityForecasts) { city in
                    cityCard(city)
                }

                if !routeStore.cityForecasts.isEmpty {
                    Button("Clear Route") {
                        routeStore.clearRoute()
                    }
                    .buttonStyle(.bordered)
                    .tint(RouteCastColors.goldenAmber)
                    .padding(.top, 4)
                }
            }
        }
        .onAppear { updateMapPosition() }
        .onChange(of: routeStore.cityForecasts.map(\.id)) { _ in
            updateMapPosition()
        }
    }

    private func cityCard(_ city: CityForecast) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(city.cityName)
                    .font(.headline)
                Spacer()
                Image(systemName: city.weather.condition.sfSymbol)
                    .foregroundStyle(city.weather.condition.color)
            }

            Text(city.weather.description)
                .font(.subheadline)
                .foregroundStyle(RouteCastColors.steeringGray.opacity(0.9))

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(city.hourly.prefix(5))) { hour in
                        VStack(spacing: 4) {
                            Text(hour.time)
                                .font(.caption)
                            Image(systemName: hour.condition.sfSymbol)
                                .foregroundStyle(hour.condition.color)
                            Text("\(Int(hour.temperature))°")
                                .font(.caption.weight(.semibold))
                        }
                        .padding(8)
                        .background(Color.white.opacity(0.75))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
            }
        }
        .padding(12)
        .background(RouteCastColors.boxBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(RouteCastColors.goldenAmber.opacity(0.35), lineWidth: 1)
        )
    }

    private var routeMapCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weather Along Route")
                .font(.headline)
                .foregroundStyle(RouteCastColors.steeringGray)

            Map(position: $mapPosition) {
                let coordinates = routeStore.cityForecasts.map(\.coordinate)

                if coordinates.count > 1 {
                    MapPolyline(coordinates: coordinates)
                        .stroke(RouteCastColors.steeringGray, lineWidth: 4)
                }

                ForEach(Array(routeStore.cityForecasts.enumerated()), id: \.element.id) { index, city in
                    Annotation(city.cityName, coordinate: city.coordinate) {
                        VStack(spacing: 4) {
                            Text(city.weather.temperature)
                                .font(.caption.weight(.bold))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(.thinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 8))

                            Image(systemName: index == 0 || index == routeStore.cityForecasts.count - 1 ? "mappin.circle.fill" : "mappin.circle")
                                .font(.title3)
                                .foregroundStyle(index == 0 || index == routeStore.cityForecasts.count - 1
                                                 ? RouteCastColors.goldenAmber
                                                 : RouteCastColors.steeringGray)
                        }
                    }
                }
            }
            .frame(height: 380)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(RouteCastColors.steeringGray.opacity(0.5), lineWidth: 1.2)
            )
        }
        .padding(10)
        .background(RouteCastColors.boxBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(RouteCastColors.goldenAmber.opacity(0.35), lineWidth: 1)
        )
    }

    private func updateMapPosition() {
        let coordinates = routeStore.cityForecasts.map(\.coordinate)
        guard !coordinates.isEmpty else {
            mapPosition = .automatic
            return
        }

        var rect = MKMapRect.null
        for coordinate in coordinates {
            let point = MKMapPoint(coordinate)
            rect = rect.union(MKMapRect(x: point.x, y: point.y, width: 0, height: 0))
        }
        mapPosition = .rect(rect.insetBy(dx: -15000, dy: -15000))
    }
}

private enum TransportMode: String, CaseIterable, Identifiable {
    case driving
    case walking
    case cycling
    case transit

    var id: String { rawValue }

    var title: String {
        switch self {
        case .driving: return "Driving"
        case .walking: return "Walking"
        case .cycling: return "Cycling"
        case .transit: return "Transit"
        }
    }
}

#Preview {
    RouteView()
        .environment(RouteStore())
}
