//
//  RouteView.swift
//  RouteCast
//
//  Created by Sophia Kager on 4/10/26.
//
import SwiftUI
import Foundation
import CoreLocation

struct RouteView: View {
    @Environment(RouteStore.self) private var routeStore
    let locationManager: LocationManager
    
    @State private var originText = ""
    @State private var destinationText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(spacing: 12) {
                    TextField("From", text: $originText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    TextField("To", text: $destinationText)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    
                    Button(action: {
                        Task {
                            await routeStore.loadRoute(
                                from: originText,
                                to: destinationText
                            )
                        }
                    }) {
                        Text("Get Weather Along Route")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .disabled(originText.isEmpty || destinationText.isEmpty || routeStore.isLoading)
                }
                .padding(.vertical, 16)
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .padding()
                
                if routeStore.isLoading {
                    ProgressView("Loading weather along route…")
                        .padding()
                } else if let error = routeStore.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else if !routeStore.cityForecasts.isEmpty {
                    ScrollView {
                        VStack(spacing: 12) {
                            ForEach(routeStore.cityForecasts) { forecast in
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(forecast.cityName)
                                                .font(.headline)
                                                .foregroundColor(RouteCastColors.steeringGray)
                                            
                                            Text(forecast.weather.description)
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Spacer()
                                        
                                        VStack(alignment: .trailing, spacing: 4) {
                                            Image(systemName: forecast.weather.condition.sfSymbol)
                                                .font(.system(size: 24))
                                                .foregroundStyle(forecast.weather.condition.color)
                                            
                                            Text(forecast.weather.temperature)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                        }
                                    }
                                    .padding()
                                    .background(RouteCastColors.boxBackground)
                                    .cornerRadius(12)
                                    .onTapGesture {
                                        // Select this city and return to hourly view
                                        let newLocation = CLLocation(
                                            latitude: forecast.coordinate.latitude,
                                            longitude: forecast.coordinate.longitude
                                        )
                                        locationManager.setLocation(newLocation)
                                        routeStore.clearRoute()
                                        originText = ""
                                        destinationText = ""
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    VStack(spacing: 8) {
                        Image(systemName: "map")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("Enter a route to see weather along the way")
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxHeight: .infinity)
                }
                
                Spacer()
            }
            .navigationTitle("Route Weather")
        }
    }
}
