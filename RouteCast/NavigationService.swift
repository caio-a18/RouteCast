//
//  LocationService.swift
//  RouteCast
//
//  Created by Vinlaw Mudehwe on 4/15/26.
//

import CoreLocation

struct NavigationData {
    var location1Index: Int
    var location2Index: Int
    var distance: Double
    var time: Double
}

struct NavigationService {
    
    // These are just conservative estimates. Accounting for changes in speed would introduce unnecessary complexity 
    static var WalkingSpeed = 5.0
    static var DrivingSpeed = 50.0
    static var TransitSpeed = 30.0
    static var CyclingSpeed = 15.0
    
    static func calculateDistance(location1: CLLocation, location2: CLLocation) -> Double {
        return location1.distance(from: location2)/1000
    }
    
    static func calculateTime(location1: CLLocation, location2: CLLocation, transportMode: TransportMode = .driving) -> Double {
        let distance = calculateDistance(location1: location1, location2: location2)
        var time: Double
        
        switch transportMode {
        case .cycling: time = distance / CyclingSpeed
        case .transit: time = distance / TransitSpeed
        case .walking: time = distance / WalkingSpeed
        default: time = distance / DrivingSpeed
        }
        
        return time
    }
    
    static func getNavigationData(locations: [CLLocation], transportMode: TransportMode = .driving) -> [NavigationData] {
        return zip(locations.indices, locations.indices.dropFirst())
            .map { i, j in
                NavigationData(
                    location1Index: i,
                    location2Index: j,
                    distance: calculateDistance(location1: locations[i], location2: locations[j]),
                    time: calculateTime(location1: locations[i], location2: locations[j], transportMode: transportMode)
                )
            }
    }
}
