//
//  ContentView.swift
//  RouteCast
//
//  Created by Caio Albuquerque on 3/5/26.
//
import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @State var routeStore            = RouteStore()
    @State private var selectedTab   = 0
    

    var body: some View {
        TabView(selection: $selectedTab) {

            HourlyView(locationManager: locationManager)
                .tabItem {
                    Image(systemName: "clock")
                    Text("Hourly")
                }
                .tag(0)

            Group {
                if let loc = locationManager.location {
                    ZStack(alignment: .top) {
                        
                        RadarView(
                            coordinates: RadarStore.shared.coordinates,
                            title: routeStore.routeLabel
                        )
                        
                        if !routeStore.routeLabel.isEmpty {
                            HStack(spacing: 6) {
                                Image(systemName: "mappin.and.ellipse")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(RouteCastColors.goldenAmber)
                                Text(routeStore.routeLabel)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(RouteCastColors.steeringGray)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 3)
                            .padding(.top, 12)
                        }
                    }
                } else {
                    Text("Getting location...")
                }
            }
            .tabItem {
                Image(systemName: "globe")
                Text("Radar")
            }
            .tag(1)

            RouteView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Route")
                }
                .tag(2)
        }
        .tint(RouteCastColors.goldenAmber)
        .environment(routeStore)
        .onChange(of: routeStore.cityForecasts.isEmpty) { wasEmpty, isNowEmpty in
            // Navigate to Hourly tab whenever a city is selected or the route is cleared.
            if !wasEmpty && isNowEmpty {
                selectedTab = 0
            }
        }
        .onChange(of: locationManager.location) { _, newLocation in
            guard let loc = newLocation else { return }

            if RadarStore.shared.coordinates.isEmpty {
                RadarStore.shared.coordinates = [loc.coordinate]
            }
        }
    }
}

#Preview {
    ContentView()
}
