//
//  AltitudeManager.swift
//  BikeComputer
//
//  Created by Allen Liang on 10/12/21.
//

import Foundation
import CoreMotion
import CoreLocation

protocol AltitudeManagerObserver: AnyObject {
    func altitudeManager(didUpdateAbsoluteAltitude feet: Double)
    func altitudeManager(didUpdateGradePercentage grade: Int)
}

extension AltitudeManagerObserver {
    func altitudeManager(didUpdateAbsoluteAltitude feet: Double) {}
    func altitudeManager(didUpdateGradePercentage grade: Int) {}
}

class AltitudeManager {
    
    var altimeterManager: CMAltimeter
    var lastLocationUsedToCalculateGrade: CLLocation?
    var lastAltitudeUsedToCalculateGrade: Double?
    var altitude: Double?
    let distanceTraveledToCalculateGrade = 10.0
    var observers = [ObjectIdentifier: AltitudeManagerObserver?]()
    
    init() {
        altimeterManager = CMAltimeter()
        start()
    }
    
    func addObserver(observer: AltitudeManagerObserver) {
        let id = ObjectIdentifier(observer)
        observers[id] = observer
    }
    
    func removeObserver(observer: AltitudeManagerObserver) {
        let id = ObjectIdentifier(observer)
        observers.removeValue(forKey: id)
    }
    
    private func isObjectStillInMemory(id: ObjectIdentifier, observer: AltitudeManagerObserver?) -> Bool {
        if observer == nil {
            observers.removeValue(forKey: id)
            return false
        } else {
            return true
        }
    }
    
    func updateAbsoluteAltitudeForObservers(absoluteAltitudeInFeet: Double) {
        for (id, observer) in observers {
            if !isObjectStillInMemory(id: id, observer: observer) {
                continue
            }
            observer?.altitudeManager(didUpdateAbsoluteAltitude: absoluteAltitudeInFeet)
        }
    }
    
    func updateGradePercentageForObservers(grade: Int) {
        for (id, observer) in observers {
            if !isObjectStillInMemory(id: id, observer: observer) {
                continue
            }
            observer?.altitudeManager(didUpdateGradePercentage: grade)
        }
    }
    
    func start() {
        if CMAltimeter.isAbsoluteAltitudeAvailable() {
            altimeterManager.startAbsoluteAltitudeUpdates(to: .main) { altitudeData, error in
                if let error = error {
                    print("error getting altitude data: ", error)
                }
                if let data = altitudeData {
                    let absoluteAltitudeInFeet = data.altitude * 3.281 // convert from meters to feet
                    self.altitude = absoluteAltitudeInFeet
                    if self.lastAltitudeUsedToCalculateGrade == nil {
                        self.lastAltitudeUsedToCalculateGrade = absoluteAltitudeInFeet
                    }
                    self.updateAbsoluteAltitudeForObservers(absoluteAltitudeInFeet: absoluteAltitudeInFeet)
                }
            }
        } else {
            // TODO: handle when not available
        }
    }
    
    func calculateGradePercentage(currentLocation: CLLocation) {
        if let lastLocation = lastLocationUsedToCalculateGrade {
            let distance = currentLocation.distance(from: lastLocation)
            if distance > distanceTraveledToCalculateGrade {
                if let lastAltitude = lastAltitudeUsedToCalculateGrade, let currentAltitude = altitude {
                    let grade = Int(((currentAltitude - lastAltitude) / distance) * 100)
                    updateGradePercentageForObservers(grade: grade)
                    self.lastAltitudeUsedToCalculateGrade = currentAltitude
                    self.lastLocationUsedToCalculateGrade = currentLocation
                }
            }
        } else {
            lastLocationUsedToCalculateGrade = currentLocation
        }
        
    }
}

extension AltitudeManager: LocationManagerObserver {
    func locationDidUpdate(location: CLLocation) {
        calculateGradePercentage(currentLocation: location)
    }
    
    func headingDidUpdate(newHeading: CLHeading) {}
    
    
}


