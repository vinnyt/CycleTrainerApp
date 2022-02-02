//
//  TrackPoint.swift
//  BikeComputer
//
//  Created by Allen Liang on 9/28/21.
//

import Foundation
import CoreLocation



struct TrackPoint: Codable, Equatable {
    var timeStamp: Date
    var latitude: Double?
    var longitude: Double?
    var altitude: Double?
    var power: Int?
    var cadence: Int?
    var heartRate: Int?
    var speed: Double?
    
    var location: CLLocation? {
        if let latitude = latitude, let longitude = longitude {
            return CLLocation(latitude: latitude, longitude: longitude)
        } else {
            return nil
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case timeStamp = "timeStamp"
        case latitude = "latitude"
        case longitude = "longitude"
        case altitude = "altitude"
        case power = "power"
        case cadence = "cadence"
        case heartRate = "heartRate"
        case speed = "speed"
    }
    
    init(dataSnapshot: DataSnapshot) {
        self.timeStamp = dataSnapshot.timeStamp
        self.latitude = dataSnapshot.coordinate?.latitude
        self.longitude = dataSnapshot.coordinate?.longitude
        self.altitude = dataSnapshot.altitude
        self.power = dataSnapshot.power
        self.cadence = dataSnapshot.cadence
        self.heartRate = dataSnapshot.heartRate
        self.speed = dataSnapshot.speed
    }
}

struct DataSnapshot {
    var timeStamp: Date
    var coordinate: CLLocationCoordinate2D?
    var power: Int
    var cadence: Int
    var heartRate: Int
    var speed: Double
    var altitude: Double?
    
    init(coordinate: CLLocationCoordinate2D?, power: Int, cadence: Int, heartRate: Int, speed: Double, altitude: Double?) {
        self.timeStamp = Date()
        self.coordinate = coordinate
        self.power = power
        self.cadence = cadence
        self.heartRate = heartRate
        self.speed = speed
        self.altitude = altitude
    }
}
