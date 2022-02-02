//
//  extensions.swift
//  BikeComputer
//
//  Created by Allen Liang on 10/7/21.
//

import Foundation
import CoreLocation
import SwiftUI

extension CLLocation: Encodable {
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case altitude
        case horizontalAccuracy
        case verticalAccuracy
        case speed
        case course
        case timestamp
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coordinate.latitude, forKey: .latitude)
        try container.encode(coordinate.longitude, forKey: .longitude)
        try container.encode(altitude, forKey: .altitude)
        try container.encode(horizontalAccuracy, forKey: .horizontalAccuracy)
        try container.encode(verticalAccuracy, forKey: .verticalAccuracy)
        try container.encode(speed, forKey: .speed)
        try container.encode(course, forKey: .course)
        try container.encode(timestamp, forKey: .timestamp)
    }
}

struct Location: Codable {
    let latitude: CLLocationDegrees
    let longitude: CLLocationDegrees
    let altitude: CLLocationDistance
    let horizontalAccuracy: CLLocationAccuracy
    let verticalAccuracy: CLLocationAccuracy
    let speed: CLLocationSpeed
    let course: CLLocationDirection
    let timestamp: Date
}

extension CLLocation {
    convenience init(model: Location) {
      self.init(coordinate: CLLocationCoordinate2DMake(model.latitude, model.longitude), altitude: model.altitude, horizontalAccuracy: model.horizontalAccuracy, verticalAccuracy: model.verticalAccuracy, course: model.course, speed: model.speed, timestamp: model.timestamp)
     }
}

extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

extension View {
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}

extension UInt16 {
    var uint8: [UInt8]  {
        return [UInt8(self >> 8), UInt8(self & 0xFF)]
    }
}
