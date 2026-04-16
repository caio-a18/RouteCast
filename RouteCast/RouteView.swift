//
//  RouteView.swift
//  RouteCast
//
//  Created by Chiebuka Onyejesi on 4/13/26.
//
import SwiftUI
import Foundation
import MapKit

// MARK: - Skeleton Card

private struct SkeletonCityCard: View {
    @State private var opacity: Double = 0.45

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(RouteCastColors.steeringGray.opacity(0.15))
                        .frame(width: 130, height: 20)
                    Capsule()
                        .fill(RouteCastColors.goldenAmber.opacity(0.25))
                        .frame(width: 110, height: 22)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 6) {
                    Circle()
                        .fill(RouteCastColors.steeringGray.opacity(0.12))
                        .frame(width: 32, height: 32)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(RouteCastColors.steeringGray.opacity(0.15))
                        .frame(width: 48, height: 22)
                }
            }

            RoundedRectangle(cornerRadius: 4)
                .fill(RouteCastColors.steeringGray.opacity(0.1))
                .frame(height: 14)

            HStack(spacing: 0) {
                ForEach(0..<5, id: \.self) { _ in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(RouteCastColors.steeringGray.opacity(0.12))
                            .frame(width: 28, height: 10)
                        Circle()
                            .fill(RouteCastColors.steeringGray.opacity(0.12))
                            .frame(width: 22, height: 22)
                        RoundedRectangle(cornerRadius: 3)
                            .fill(RouteCastColors.steeringGray.opacity(0.12))
                            .frame(width: 22, height: 10)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, 12)
            .background(Color.white.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(16)
        .background(RouteCastColors.boxBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.06), radius: 10, x: 0, y: 3)
        .opacity(opacity)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.85).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }
        }
    }
}

// MARK: - RouteView

struct RouteView: View {
    @Environment(RouteStore.self) private var routeStore

    @State private var pointA = ""
    @State private var pointB = ""
    @State private var departure = Date()
    @State private var selectedMode: TransportMode = .driving
    @State private var mapPosition: MapCameraPosition = .automatic
    @State private var isMapFullScreen = false

    private var canSearch: Bool {
        !pointA.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !pointB.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !routeStore.isLoading
    }

    var body: some View {
        VStack(spacing: 0) {
            formSection
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

            resultSection
        }
        .background(RouteCastColors.pageBackground.ignoresSafeArea())
        .fullScreenCover(isPresented: $isMapFullScreen) {
            fullScreenMapView
        }
    }

    // MARK: - Form

    private var formSection: some View {
        VStack(spacing: 14) {
            fieldInput(label: "FROM", placeholder: "City or address", text: $pointA)
            fieldInput(label: "TO",   placeholder: "City or address", text: $pointB)

            HStack(spacing: 10) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("DEPARTURE")
                        .font(.caption.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(RouteCastColors.steeringGray.opacity(0.45))
                    DatePicker("", selection: $departure, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)

                VStack(alignment: .leading, spacing: 5) {
                    Text("MODE")
                        .font(.caption.weight(.bold))
                        .tracking(1.2)
                        .foregroundStyle(RouteCastColors.steeringGray.opacity(0.45))
                    Picker("Mode", selection: $selectedMode) {
                        ForEach(TransportMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .tint(RouteCastColors.steeringGray)
                }
                .padding(12)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
            }

            HStack(spacing: 10) {
                Button {
                    Task {
                        await routeStore.loadRoute(
                            from: pointA.trimmingCharacters(in: .whitespacesAndNewlines),
                            to: pointB.trimmingCharacters(in: .whitespacesAndNewlines),
                            departure: departure,
                            transportMode: selectedMode
                        )
                    }
                } label: {
                    Text("Get Route Weather")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(
                            canSearch
                            ? LinearGradient(colors: [RouteCastColors.goldenAmber, RouteCastColors.warmOrange],
                                             startPoint: .leading, endPoint: .trailing)
                            : LinearGradient(colors: [Color.gray.opacity(0.3), Color.gray.opacity(0.3)],
                                             startPoint: .leading, endPoint: .trailing)
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .shadow(color: canSearch ? RouteCastColors.goldenAmber.opacity(0.35) : .clear,
                                radius: 8, x: 0, y: 4)
                }
                .disabled(!canSearch)

                if !routeStore.cityForecasts.isEmpty {
                    Button {
                        routeStore.clearRoute()
                    } label: {
                        Text("Clear")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(RouteCastColors.steeringGray.opacity(0.55))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 15)
                            .background(RouteCastColors.steeringGray.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
            }
        }
    }

    private func fieldInput(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.caption.weight(.bold))
                .tracking(1.5)
                .foregroundStyle(RouteCastColors.steeringGray.opacity(0.45))
            TextField(placeholder, text: text)
                .textInputAutocapitalization(.words)
                .disableAutocorrection(true)
                .font(.body.weight(.medium))
                .foregroundStyle(RouteCastColors.steeringGray)
        }
        .padding(14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
    }

    // MARK: - Results

    private var resultSection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let error = routeStore.errorMessage {
                    Text(error)
                        .foregroundStyle(.red)
                        .font(.subheadline)
                        .padding(.horizontal, 20)
                        .padding(.top, 6)
                }

                if routeStore.isLoading {
                    skeletonSection
                } else if routeStore.cityForecasts.isEmpty, routeStore.errorMessage == nil {
                    emptyState
                } else {
                    if !routeStore.cityForecasts.isEmpty {
                        routeMapCard
                            .padding(.horizontal, 20)
                    }
                    ForEach(Array(routeStore.cityForecasts.enumerated()), id: \.element.id) { index, city in
                        cityCard(city, index: index)
                            .padding(.horizontal, 20)
                    }
                }
            }
            .padding(.bottom, 110)
        }
        .onAppear { updateMapPosition() }
        .onChange(of: routeStore.cityForecasts.map(\.id)) { _ in
            updateMapPosition()
        }
    }

    // MARK: - Skeleton

    private var skeletonSection: some View {
        VStack(spacing: 16) {
            ForEach(0..<3, id: \.self) { _ in
                SkeletonCityCard()
                    .padding(.horizontal, 20)
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "map")
                .font(.system(size: 56))
                .foregroundStyle(RouteCastColors.goldenAmber.opacity(0.5))
            Text("Enter a start and destination\nto see weather along your route.")
                .font(.subheadline)
                .foregroundStyle(RouteCastColors.steeringGray.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    // MARK: - City Card

    private func cityCard(_ city: CityForecast, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(city.cityName)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(RouteCastColors.steeringGray)
                    Text("\(index == 0 ? "Departure" : "Est. arrival") \(city.arrivalTime.formatted(date: .omitted, time: .shortened))")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 4)
                        .background(index == 0 ? RouteCastColors.steeringGray : RouteCastColors.goldenAmber)
                        .clipShape(Capsule())
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Image(systemName: city.weather.condition.sfSymbol)
                        .font(.system(size: 32))
                        .foregroundStyle(city.weather.condition.color)
                    Text(city.weather.temperature)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(RouteCastColors.steeringGray)
                }
            }

            Text(city.weather.description)
                .font(.subheadline)
                .foregroundStyle(RouteCastColors.steeringGray.opacity(0.65))

            // Fixed 5-column hourly row — no nested scroll
            HStack(spacing: 0) {
                ForEach(Array(city.hourly.prefix(5))) { item in
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

    // MARK: - Map Card

    private var routeMapCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Text("ROUTE MAP")
                    .font(.caption.weight(.semibold))
                    .tracking(1.5)
                    .foregroundStyle(RouteCastColors.steeringGray.opacity(0.4))
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(RouteCastColors.steeringGray.opacity(0.1))
            }

            ZStack(alignment: .topTrailing) {
                routeMap
                    .frame(height: 360)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.08), radius: 10, x: 0, y: 4)

                Button {
                    updateMapPosition()
                    isMapFullScreen = true
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(RouteCastColors.steeringGray)
                        .padding(10)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .overlay(
                            Circle()
                                .strokeBorder(Color.white.opacity(0.8), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 2)
                }
                .padding(12)
            }
        }
        .padding(16)
        .background(RouteCastColors.boxBackground)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 4)
    }

    private var routeMap: some View {
        Map(position: $mapPosition) {
            let forecasts = routeStore.cityForecasts
            let coordinates = forecasts.map(\.coordinate)

            if coordinates.count > 1 {
                MapPolyline(coordinates: coordinates)
                    .stroke(RouteCastColors.goldenAmber, lineWidth: 3.5)
            }

            ForEach(Array(forecasts.enumerated()), id: \.element.id) { index, city in
                let isEndpoint = index == 0 || index == forecasts.count - 1
                Annotation(city.cityName, coordinate: city.coordinate) {
                    VStack(spacing: 3) {
                        HStack(spacing: 4) {
                            Image(systemName: city.weather.condition.sfSymbol)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(city.weather.condition.color)
                            Text(city.weather.temperature)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(RouteCastColors.steeringGray)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(RouteCastColors.goldenAmber, lineWidth: 1.5)
                        )
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                        Image(systemName: isEndpoint ? "mappin.circle.fill" : "circle.fill")
                            .font(isEndpoint ? .title3 : .caption)
                            .foregroundStyle(isEndpoint
                                             ? RouteCastColors.goldenAmber
                                             : RouteCastColors.steeringGray.opacity(0.4))
                    }
                }
            }
        }
    }

    private var fullScreenMapView: some View {
        ZStack(alignment: .topTrailing) {
            routeMap
                .ignoresSafeArea()

            Button {
                isMapFullScreen = false
                updateMapPosition()
            } label: {
                Image(systemName: "arrow.down.right.and.arrow.up.left")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(RouteCastColors.steeringGray)
                    .padding(12)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .strokeBorder(Color.white.opacity(0.8), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 3)
            }
            .padding(.top, 16)
            .padding(.trailing, 16)
        }
        .onAppear {
            // Re-fit every time fullscreen opens so prior manual zoom does not persist.
            updateMapPosition()
        }
    }

    // MARK: - Helpers

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

enum TransportMode: String, CaseIterable, Identifiable {
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
