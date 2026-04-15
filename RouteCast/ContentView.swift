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
                    RadarView(latitude: loc.coordinate.latitude,
                              longitude: loc.coordinate.longitude)
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
    }
}

#Preview {
    ContentView()
}
