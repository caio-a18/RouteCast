//
//  ContentView.swift
//
//  Created by Caio Albuquerque on 3/5/26.
//
import SwiftUI
import CoreLocation

struct ContentView: View {
    @StateObject var locationManager = LocationManager()
    @State var routeStore            = RouteStore()
    @State private var selectedTab   = 0

    init() {
        UITabBar.appearance().isHidden = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HourlyView(locationManager: locationManager)
                    .tag(0)

                radarTab
                    .tag(1)

                RouteView()
                    .tag(2)
            }
            .environment(routeStore)
            .safeAreaInset(edge: .bottom) { Color.clear.frame(height: 88) }
            .onChange(of: locationManager.location) { _, newLocation in
                guard let loc = newLocation else { return }
                if RadarStore.shared.coordinates.isEmpty {
                    RadarStore.shared.coordinates = [loc.coordinate]
                }
            }

            floatingTabBar
        }
    }

    // MARK: - Radar Tab

    @ViewBuilder
    private var radarTab: some View {
        if locationManager.location != nil {
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
            .padding(.bottom, 110)
        } else {
            VStack {
                Spacer()
                Text("Getting location…")
                    .foregroundStyle(RouteCastColors.steeringGray.opacity(0.5))
                Spacer()
            }
        }
    }

    // MARK: - Floating Tab Bar

    private var floatingTabBar: some View {
        HStack(spacing: 0) {
            tabButton(icon: "clock",  selectedIcon: "clock.fill", title: "Hourly", tag: 0)
            tabButton(icon: "globe",  selectedIcon: "globe",      title: "Radar",  tag: 1)
            tabButton(icon: "map",    selectedIcon: "map.fill",   title: "Route",  tag: 2)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.14), radius: 20, x: 0, y: 6)
        .padding(.horizontal, 36)
        .padding(.bottom, 24)
    }

    private func tabButton(icon: String, selectedIcon: String, title: String, tag: Int) -> some View {
        let isSelected = selectedTab == tag
        return Button {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tag
            }
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isSelected ? selectedIcon : icon)
                    .font(.system(size: 19, weight: isSelected ? .semibold : .regular))
                Text(title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .regular))
            }
            .foregroundStyle(isSelected ? RouteCastColors.goldenAmber : RouteCastColors.steeringGray.opacity(0.38))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background(
                isSelected ? RouteCastColors.goldenAmber.opacity(0.12) : Color.clear,
                in: Capsule()
            )
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
