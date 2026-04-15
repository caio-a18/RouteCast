//
//  RadarStore.swift
//  RouteCast
//
//  Created by Sophia Kager on 4/15/26.
//
import CoreLocation

@Observable
final class RadarStore {
    static let shared = RadarStore()

    var coordinates: [CLLocationCoordinate2D] = []
}
