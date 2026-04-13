//
//  RouteCastColors.swift
//  RouteCast
//
//  Created by Caio Albuquerque on 4/11/26.
//

import SwiftUI

// App wide color palette derived from the RouteCast logo
struct RouteCastColors {

    // Brand colors

    /// Bright yellow — top ray of the logo sun  (#FFD700)
    static let sunYellow = Color(red: 1.000, green: 0.843, blue: 0.000)

    /// Golden amber — primary brand color, inner ring and upper-side rays
    static let goldenAmber = Color(red: 0.957, green: 0.647, blue: 0.098)

    /// Warm orange — lower side rays of the logo sun
    static let warmOrange = Color(red: 0.902, green: 0.502, blue: 0.098)

    /// Deep orange — bottom ray of the logo sun
    static let deepOrange = Color(red: 0.800, green: 0.380, blue: 0.078)

    /// Charcoal gray — steering wheel in the logo
    static let steeringGray = Color(red: 0.239, green: 0.239, blue: 0.239)

    // UI Surface Colors

    /// Very light amber — card / box backgrounds
    static let boxBackground = Color(red: 1.000, green: 0.973, blue: 0.878)

    /// Pure white — main page background
    static let pageBackground = Color.white
}
