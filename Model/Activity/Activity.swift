//
//  Activity.swift
//  BikeComputer
//
//  Created by Allen Liang on 9/28/21.
//

import Foundation
import CoreLocation

enum ActivityStatus {
    case started
    case notStarted
    case autoPaused
    case complete
    case userPaused
}

protocol CentralDataSource {
    func getPower() -> Int
    func getHeartRate() -> Int
    func getSpeed() -> Double
    func getCadence() -> Int
    func getAltitude() -> Double
    func getLocationCoordinate() -> CLLocationCoordinate2D?
}

protocol ActivityDelegate: CentralDataSource {
    func activity(activityDidUpdate activitySnapshot: ActivitySnapShot, lapSnapshot: LapSnapshot)
    func activity(activityStatusDidChange status: ActivityStatus)
}

class Activity {
    private var startDate = Date()
    private(set) var time: Int = 0
    private(set) var trackPoints = [TrackPoint]()
    private(set) var delegate: ActivityDelegate
    private var activityTimer: Timer?
    private var statusTimer: Timer?
    private(set) var status: ActivityStatus = .notStarted {
        didSet {
            delegate.activity(activityStatusDidChange: status)
        }
    }
    private(set) var currentLap: Lap = Lap()
    private(set) var distance = 0.0
    private var lastAltitude: Double?
    var elevationGain: Double = 0.0
    private var avgSpeedSum: Double = 0.0 // TODO: suggestion: do these avg calculations somewhere else
    private(set) var avgSpeed: Double = 0.0
    private var avgHeartRateSum = 0
    private(set) var avgHeartRate = 0
    private var avgPowerSum = 0
    private var avgPower = 0
    let minSpeed = 3.0
    let minPower = 20
    
    private(set) var laps = [SavedLap]()
    
    
    init(delegate: ActivityDelegate) {
        self.delegate = delegate
    }
    
    func getCoordinates() -> [CLLocationCoordinate2D] {
        let coordinates: [CLLocationCoordinate2D] = trackPoints.map {
            if let latitude = $0.latitude, let longitude = $0.longitude {
                return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            } else {
                return nil
            }
        }.compactMap{ $0 }
        
        return coordinates
    }
    
    func startActivity() { // TODO: init date
        if status == .notStarted {
            status = .started
            startDate = Date()
            createActivityTimer()
            createStatusTimer()
        }
    }
    
    func userPausedActivity() {
        if status != .userPaused {
            activityTimer?.invalidate()
            activityTimer = nil
            status = .userPaused
        }
    }
    
    func autoPauseActivity() {
        if status != .autoPaused {
            activityTimer?.invalidate()
            activityTimer = nil
            status = .autoPaused
        }
    }
    
    func stopAndSaveActivity() -> NewSavedActivity{
        activityTimer?.invalidate()
        statusTimer?.invalidate()
        activityTimer = nil
        statusTimer = nil
        status = .complete
        
        //save
        print("save")
        let viewContext = PersistenceContainer.shared.container.viewContext
        
        let newSavedActivity = NewSavedActivity(context: viewContext)
        newSavedActivity.startDate = startDate
        newSavedActivity.time = time
        newSavedActivity.distance = distance
        
        let encoder = JSONEncoder()
        
        do {
            let trackPointsData = try encoder.encode(trackPoints)
            newSavedActivity.trackPointsString = String(data: trackPointsData, encoding: .utf8) ?? ""
        } catch {
            print("error encoding track points: ", error)
        }
        
        do {
            let savedLapsData = try encoder.encode(laps)
            newSavedActivity.lapsString = String(data: savedLapsData, encoding: .utf8)
        } catch {
            print("error encoding laps: ", error)
        }
        
        do {
            try viewContext.save()
        } catch {
            print("error saving context: \(error)")
        }
        
        Profile.default.calculateBestPowers()
        
        return newSavedActivity
    }
    
    private func playActivity() {
        if status == .autoPaused || status == .userPaused {
            activityTimer?.invalidate()
            activityTimer = nil
            createActivityTimer()
            status = .started
        }
    }
    
    func resume() {
        playActivity()
    }
    
    func newLap() {
        // add lap to laps
        laps.append(currentLap.getSavedLap())
        currentLap.reset()
        GlobalObject.shared.show(systemImage: "goforward", message: "Lap \(laps.count)")
    }
    
    private func addTrackPoint(dataSnapshot: DataSnapshot) {
        let trackPoint = TrackPoint(dataSnapshot: dataSnapshot)
        trackPoints.append(trackPoint)
    }
    
    private func statusTimerFired() {
        if !Profile.default.autoPause {
            if status == .autoPaused {
                playActivity()
            }
            return
        }
        let speed = delegate.getSpeed()
        let power = delegate.getPower()
       
        if speed < minSpeed && power < minPower && status != .userPaused{
            autoPauseActivity()
        } else if status != .userPaused {
            playActivity()
        }
    }
    
    private func activityTimerFired() {
        let dataSnapshot = DataSnapshot(coordinate: delegate.getLocationCoordinate(),
                                        power: delegate.getPower(),
                                        cadence: delegate.getCadence(),
                                        heartRate: delegate.getHeartRate(),
                                        speed: delegate.getSpeed(),
                                        altitude: delegate.getAltitude())
        
        self.addTrackPoint(dataSnapshot: dataSnapshot)
        self.currentLap.addDataSnapshot(dataSnapshot: dataSnapshot)
        
        self.time += 1
        self.updateDistance()
        self.updateElevationGain()
        self.updateAvgSpeed()
        self.updateAvgHeartRate()
        self.updateAvgPower()
        
        self.updateDelegate()
        
    }
    
    private func updateAvgPower() {
        let currentPower = delegate.getPower()
        avgPowerSum += currentPower
        avgPower = avgPowerSum / time
    }
    
    private func updateAvgHeartRate() {
        let currentHeartRate = delegate.getHeartRate()
        avgHeartRateSum += currentHeartRate
        avgHeartRate = avgHeartRateSum / time
    }
    
    private func updateAvgSpeed() {
        let currentSpeed = delegate.getSpeed()
        avgSpeedSum += currentSpeed
        avgSpeed = avgSpeedSum / Double(time)
    }
    
    private func updateElevationGain() {
        let threshold = 1.0
        if let lastAltitude = lastAltitude {
            let currentAltitude = delegate.getAltitude()
            if currentAltitude > lastAltitude + threshold {
                let gain = currentAltitude - lastAltitude
                elevationGain += gain
                self.lastAltitude = currentAltitude
            } else {
                self.lastAltitude = currentAltitude
            }
        } else {
            lastAltitude = delegate.getAltitude()
        }
    }
    
    // TODO: need to keep track of last valid location in case locations are nil
    private func updateDistance() {
        let numOfTrackPoints = trackPoints.count
        if numOfTrackPoints > 1 {
            if let lastLocation = trackPoints[numOfTrackPoints - 2].location,
               let currentLocation = trackPoints[numOfTrackPoints - 1].location {
                distance += lastLocation.distance(from: currentLocation) * 0.000621371
            }
        }
    }
    
    private func updateDelegate() {
        let activitySnapshot = ActivitySnapShot(time: self.time,
                                                distance: self.distance,
                                                elevationGain: self.elevationGain,
                                                avgSpeed: self.avgSpeed,
                                                avgPower: self.avgPower,
                                                avgHeartRate: self.avgHeartRate)
        
        let lapSnapshot = currentLap.getLapSnapshot()
        
        delegate.activity(activityDidUpdate: activitySnapshot, lapSnapshot: lapSnapshot)
    }
    
    private func createActivityTimer() {
        activityTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            self.activityTimerFired()
        })
    }
    
    private func createStatusTimer() {
        statusTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            self.statusTimerFired()
        })
    }
}

struct ActivitySnapShot {
    let time: Int
    let distance: Double
    let elevationGain: Double
    let avgSpeed: Double
    let avgPower: Int
    let avgHeartRate: Int
}

struct LapSnapshot {
    let lapTime: Int
    let lapPower: Int
    let lapSpeed: Double
    let lapHeartRate: Int
    let lapDistance: Double
}
