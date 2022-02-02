//
//  Lap.swift
//  BikeComputer
//
//  Created by Allen Liang on 10/12/21.
//

import Foundation
import CoreLocation

class SavedLap: Codable {
    let lapTime: Int
    let lapPower: Int
    let lapHeartRate: Int
    let lapSpeed: Double
    let lapDistance: Double
    
    init(lapTime: Int, lapPower: Int, lapHeartRate: Int, lapSpeed: Double, lapDistance: Double) {
        self.lapTime = lapTime
        self.lapPower = lapPower
        self.lapHeartRate = lapHeartRate
        self.lapSpeed = lapSpeed
        self.lapDistance = lapDistance
    }
}

class Lap {
    private(set) var lapTime = 0
    private(set) var lapPower = 0
    private(set) var lapHeartRate = 0
    private(set) var lapSpeed = 0.0
    private(set) var lapDistance = 0.0
    
    private var lapPowerCount = 0
    private var lapPowerSum = 0
    
    private var lapSpeedCount = 0
    private var lapSpeedSum = 0.0

    private var lapHeartRateCount = 0
    private var lapHeartRateSum = 0
    
    private var lastCoordinate: CLLocationCoordinate2D? = nil
    
    func addDataSnapshot(dataSnapshot: DataSnapshot) {
        lapTime += 1
        
        lapPowerSum += dataSnapshot.power
        lapPowerCount += 1
        lapPower = lapPowerSum / lapPowerCount
        
        lapSpeedSum += dataSnapshot.speed
        lapSpeedCount += 1
        lapSpeed = lapSpeedSum / Double(lapSpeedCount)
        
        lapHeartRateSum += dataSnapshot.heartRate
        lapHeartRateCount += 1
        lapHeartRate = lapHeartRateSum / lapHeartRateCount
        
        updateDistance(currentCoordinate: dataSnapshot.coordinate)
    }
    
    func getSavedLap() -> SavedLap{
        return SavedLap(lapTime: self.lapTime, lapPower: self.lapPower, lapHeartRate: self.lapHeartRate, lapSpeed: self.lapSpeed, lapDistance: self.lapDistance)
    }
    
    func getLapSnapshot() -> LapSnapshot {
        return LapSnapshot(lapTime: self.lapTime,
                                   lapPower: self.lapPower,
                                   lapSpeed: self.lapSpeed,
                                   lapHeartRate: self.lapHeartRate,
                                   lapDistance: self.lapDistance)
        }
    
    private func updateDistance(currentCoordinate: CLLocationCoordinate2D?) {
        guard let currentCoordinate = currentCoordinate else { return }
        if let lastCoordinate = lastCoordinate {
            let lastLocation = CLLocation(latitude: lastCoordinate.latitude, longitude: lastCoordinate.longitude)
            let currentLocation = CLLocation(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
            let distance = lastLocation.distance(from: currentLocation)
            
            lapDistance += distance * 0.000621371
            self.lastCoordinate = currentCoordinate
        } else {
            lastCoordinate = currentCoordinate
        }
    }
    
    func reset() {
        lapTime = 0
        lapPower = 0
        lapSpeed = 0
        lapHeartRate = 0
        lapDistance = 0
        
        lapPowerCount = 0
        lapPowerSum = 0
        
        lapSpeedCount = 0
        lapSpeedSum = 0
        
        lapHeartRateCount = 0
        lapHeartRateSum = 0
        
        lastCoordinate = nil
    }
}

extension Lap: Equatable {
    static func == (lhs: Lap, rhs: Lap) -> Bool {
        return lhs.lapTime == rhs.lapTime &&
        lhs.lapPower == rhs.lapPower &&
        lhs.lapSpeed == rhs.lapSpeed &&
        lhs.lapDistance == rhs.lapDistance &&
        lhs.lapHeartRate == rhs.lapHeartRate
    }
    
    
}
