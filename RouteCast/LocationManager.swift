//
//  LocationManager.swift
//  RouteCast
//
//  Created by Sophia Kager on 4/10/26.
//
import CoreLocation
import Foundation
import Combine

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    
    @Published var location: CLLocation?

    override init() {
        super.init()
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first
    }

    /// Set location manually (used when selecting a city from route view)
    func setLocation(_ newLocation: CLLocation) {
        self.location = newLocation
    }
    
}
