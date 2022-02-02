//
//  LocationManager.swift
//  BikeComputer
//
//  Created by Allen Liang on 8/29/21.
//

import Foundation
import CoreLocation
import UIKit

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    var locationManager: CLLocationManager!

    var currentHeading: CLHeading?
    var observers = [ObjectIdentifier: LocationManagerObserver?]()
    var headingTimer: Timer?
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy =  kCLLocationAccuracyBestForNavigation
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.requestWhenInUseAuthorization()
        startUpdating()
        locationManager.showsBackgroundLocationIndicator = true
        createHeadingTimer()
    }
    
    func stopUpdating() {
        locationManager.stopUpdatingHeading()
        locationManager.stopUpdatingLocation()
    }
    
    func startUpdating() {
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    func addObserver(observer: LocationManagerObserver) {
        let id = ObjectIdentifier(observer)
        observers[id] = observer
    }
    
    func removeObserver(observer: LocationManagerObserver) {
        let id = ObjectIdentifier(observer)
        observers.removeValue(forKey: id)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return}
        
        let mph = last.speed / 1609.34 * 3600
        if mph > 2 && mph < 60.0 {
            updateSpeedForObservers(mph: mph)
        } else if mph < 2 {
            updateSpeedForObservers(mph: 0.0)
        }
        if let location = locationManager.location {
            updateLocationForObservers(location: location)
        }
        
    }
    
    private func isObjectStillInMemory(id: ObjectIdentifier, observer: LocationManagerObserver?) -> Bool {
        if observer == nil {
            observers.removeValue(forKey: id)
            return false
        } else {
            return true
        }
    }
    
    func updateLocationForObservers(location: CLLocation) {
        for (id, observer) in observers {
            if !isObjectStillInMemory(id: id, observer: observer) {
                continue
            }
            observer?.locationManager(didUpdateLocation: location)
        }
    }
    
    func updateHeadingForObservers(newHeading: CLHeading) {
        for (id, observer) in observers {
            if !isObjectStillInMemory(id: id, observer: observer) {
                continue
            }
            observer?.locationManager(didUpdateHeading: newHeading)
        }
    }
    
    func updateSpeedForObservers(mph: Double) {
        for (id, observer) in observers {
            if !isObjectStillInMemory(id: id, observer: observer) {
                continue
            }
            observer?.locationManager(didUpdateSpeed: mph)
        }
    }
    
    func createHeadingTimer() { // TODO: reduce energy usage
        headingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            guard let currentHeading = self.locationManager.heading else { return }
            self.updateHeadingForObservers(newHeading: currentHeading)
        })
    }
}

protocol LocationManagerObserver: AnyObject {
    func locationManager(didUpdateLocation location: CLLocation)
    
    func locationManager(didUpdateHeading heading: CLHeading)
    
    func locationManager(didUpdateSpeed mph: Double)
}

extension LocationManagerObserver {
    func locationManager(didUpdateLocation location: CLLocation) {}
    
    func locationManager(didUpdateHeading heading: CLHeading) {}
    
    func locationManager(didUpdateSpeed mph: Double) {}
}
