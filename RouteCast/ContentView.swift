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

    var body: some View {
        TabView {

            HourlyView()
                .tabItem {
                    Image(systemName: "clock")
                    Text("Hourly")
                }
            
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
            
            RouteView()
                .tabItem {
                    Image(systemName: "map")
                    Text("Route")
                }
        }
        .tint(RouteCastColors.goldenAmber)
        .environment(routeStore)
    }
}

#Preview {
    ContentView()
}
