//
//  PeripheralViewModel.swift
//  BikeComputer
//
//  Created by Allen Liang on 8/19/21.
//

import Foundation
import CoreLocation
import CoreBluetooth
import MapKit

enum DataType: String, CaseIterable, Identifiable, Codable {
    var id: String { self.rawValue }
    
    case power = "Power"
    case heartRate = "Heart Rate"
    case cadence = "Cadence"
    case speed = "Speed"
    case time = "Time"
    case distance = "Distance"
    case threeSecondPower = "Three Second Power"
    case lapTime = "Lap Time"
    case lapPower = "Lap Power"
    case map = "Map"
    case interval = "Power Zone"
    case grade = "Grade"
    case altitude = "Altitude"
    case elevationGain = "Elevation Gain"
    case avgSpeed = "Average Speed"
    case avgHeartRate = "Average Heart Rate"
    case avgPower = "Average Power"
}

class PeripheralViewModel: ObservableObject {
    @Published var dataMap: [DataType: Any] = [.power: 0,
                                                .heartRate: 0,
                                                .cadence: 0,
                                                .speed: 0.0,
                                                .time: 0,
                                               .distance: 0.0,
                                               .threeSecondPower: 0,
                                               .lapTime: 0,
                                               .lapPower: 0,
                                               .grade: 0,
                                               .altitude: 0.0,
                                               .elevationGain: 0.0,
                                                .avgSpeed: 0.0,
                                                .avgHeartRate: 0,
                                                .avgPower: 0]
    
    @Published var activityStatus: ActivityStatus = .notStarted
    @Published var discoveredHeartRatePeripherals = [Peripheral]()
    @Published var discoveredPowerMeterPeripherals = [Peripheral]()
    @Published var discoveredCadencePeripherals = [Peripheral]()
    @Published var discoveredSpeedPeripherals = [Peripheral]()
    @Published var threeSecondPower = 0
    @Published var currentHeading: CLHeading?
    @Published var selectedZone = Zone.zone1
    @Published var powerZonePercentage = 0.0
    @Published var powerRange = [0,0]
    
    @Published var cadenceFromSensor = 0
    @Published var speedFromSensor = 0.0
    
    var currentActivityMap: ActivityMap
    
    var lastThreePower = [0,0,0]
    var location: CLLocation?
    var currentActivity: Activity!

    var viewContext = PersistenceContainer.shared.container.viewContext
    var savedRoute: SavedRoute?
    var isActivityActive = false
    
    var heartRateManager: HeartRateManager!
    var powerMeterManager: PowerMeterManager!
    var cadenceSensorManager: CadenceSensorManager!
    var speedSensorManager: SpeedSensorManager!
    var locationManager: LocationManager!
    var altitudeManager: AltitudeManager!
    
    init() {
        //setup Activity
        currentActivityMap = ActivityMap()
        currentActivity = Activity(delegate: self)
        handleSelectedPowerZoneChange()
        
        //setup Managers
        heartRateManager = HeartRateManager(delegate: self)
        powerMeterManager = PowerMeterManager(delegate: self)
        cadenceSensorManager = CadenceSensorManager(delegate: self)
        speedSensorManager = SpeedSensorManager(delegate: self)
        locationManager = LocationManager()
        locationManager.addObserver(observer: self)
        locationManager.addObserver(observer: currentActivityMap)
        altitudeManager = AltitudeManager()
        altitudeManager.addObserver(observer: self)
        locationManager.addObserver(observer: altitudeManager)
        
        //setup Notifications
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.didBecomeActiveNotification, object: nil)

    }

    
    @objc func appMovedToBackground() {
        if activityStatus == .notStarted {
            disconnectPeripherals()
        }
        if activityStatus == .notStarted || activityStatus == .complete {
            locationManager.stopUpdating()
        }
    }
    
    @objc func appMovedToForeground() {
        if activityStatus == .notStarted {
            connectToLastConnectedPeripherals()
        }
        locationManager.startUpdating()
    }
    
    func startActivity() {
        resetActivity()
        currentActivity.startActivity()
        currentActivityMap.clearCurrentPolylines()
        currentActivityMap.draw = true
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    func userPaused() {
        currentActivity.userPausedActivity()
    }
    
    func resume() {
        currentActivity.resume()
    }
    
    
    func lap() {
        currentActivity.newLap()
    }
    
    func resetActivity() {
        currentActivity = Activity(delegate: self)
        dataMap[.time] = 0
        dataMap[.avgHeartRate] = 0
        dataMap[.avgPower] = 0
        dataMap[.avgSpeed] = 0.0
        dataMap[.distance] = 0.0
        dataMap[.lapTime] = 0
        dataMap[.lapPower] = 0
        dataMap[.elevationGain] = 0.0
        dataMap[.threeSecondPower] = 0
    }
    
//MARK: - HEARTRATE
    
    func scanForHeartRatePeripherals() {
        heartRateManager.scanForPeripherals()
    }
    
    func stopScanningForHeartRatePeripherals() {
        heartRateManager.stopScanning()
    }
    
    func connectToHeartRatePeripheral(peripheral: Peripheral) {
        heartRateManager.connectTo(peripheral: peripheral)
    }
    
    func disconnectHeartRatePeripheral() {
        heartRateManager.disconnect()
    }
    
//MARK: - POWERMETER
    
    func scanForPowerMeterPeripherals() {
        powerMeterManager.scanForPeripherals()
    }
    
    func stopScanningForPowerMeterPeripherals() {
        powerMeterManager.stopScanning()
    }
    
    func connectToPowerMeterPeripheral(peripheral: Peripheral) {
        powerMeterManager.connectTo(peripheral: peripheral)
    }
    
    func disconnectPowerMeterPeripheral() {
        powerMeterManager.disconnect()
    }
    
//MARK: - CADENCE
    
    func scanForCadencePeripherals() {
        cadenceSensorManager.scanForPeripherals()
    }
    
    func stopScanningForCadencePeripherals() {
        cadenceSensorManager.stopScanning()
    }
    
    func connectToCadencePeripheral(peripheral: Peripheral) {
        cadenceSensorManager.connectTo(peripheral: peripheral)
    }
    
    func disconnectCadencePeripheral() {
        cadenceSensorManager.disconnect()
    }
    
//MARK: - SPEED
    
    func scanForSpeedPeripherals() {
        speedSensorManager.scanForPeripherals()
    }
    
    func stopScanningForSpeedPeripherals() {
        speedSensorManager.stopScanning()
    }
    
    func connectToSpeedPeripheral(peripheral: Peripheral) {
        speedSensorManager.connectTo(peripheral: peripheral)
    }
    
    func disconnectSpeedPeripheral() {
        speedSensorManager.disconnect()
    }
    
    func disconnectPeripherals() {
        disconnectHeartRatePeripheral()
        disconnectPowerMeterPeripheral()
        disconnectCadencePeripheral()
        disconnectSpeedPeripheral()
    }
    
    func connectToLastConnectedPeripherals() {
        heartRateManager.tryToConnectToLastPeripheral()
        powerMeterManager.tryToConnectToLastPeripheral()
        cadenceSensorManager.tryToConnectToLastPeripheral()
        speedSensorManager.tryToConnectToLastPeripheral()
        
    }
    //MARK: - Power Zone
    
    func handleSelectedPowerZoneChange() {
        let zones = Profile.default.zones

        switch selectedZone {
        case .zone1:
            powerRange = zones["1"] ?? [0,0]
        case .zone2:
            powerRange = zones["2"] ?? [0,0]
        case .zone3:
            powerRange = zones["3"] ?? [0,0]
        case .zone4:
            powerRange = zones["4"] ?? [0,0]
        case .zone5:
            powerRange = zones["5"] ?? [0,0]
        case .zone6:
            powerRange = zones["6"] ?? [0,0]
        }
    }
    
    func updateZonePercentage() {
        let low = abs(powerRange[0] - 20)
        let high = powerRange[1] + 20
        
        if threeSecondPower < low {
            powerZonePercentage = 0.0
        } else if threeSecondPower >= low && threeSecondPower <= high {
            let nom = threeSecondPower - low
            let denom = high - low
            powerZonePercentage = Double(nom) / Double(denom)
        } else {
            powerZonePercentage = 1.0
        }
    }
}

// MARK: - PeripheralManagers

extension PeripheralViewModel: HeartRateManagerDelegate {
    func heartRateManager(didDisconnect: Peripheral) {
        dataMap[.heartRate] = 0
    }
    
    func heartRateManager(heartRateDidUpdate heartRate: Int) {
        dataMap[.heartRate] = heartRate
    }
    
    func heartRateManager(discoveredPeripheralListChanged discoveredPeripheralList: [Peripheral]) {
        discoveredHeartRatePeripherals = discoveredPeripheralList
    }
}



extension PeripheralViewModel: PowerMeterManagerDelegate {
    func powerMeterManager(didDisconnect peripheral: Peripheral) {
        dataMap[.power] = 0
    }
    
    func powerMeterManager(didUpdatePower power: Int) {
        dataMap[.power] = power
        
        lastThreePower[0] = lastThreePower[1]
        lastThreePower[1] = lastThreePower[2]
        lastThreePower[2] = power
        
        threeSecondPower = lastThreePower.reduce(0, +) / 3
        dataMap[.threeSecondPower] = lastThreePower.reduce(0, +) / 3
        
        updateZonePercentage()
    }
    
    func powerMeterManager(discoveredPeripheralListChanged discoveredPeripheralList: [Peripheral]) {
        discoveredPowerMeterPeripherals = discoveredPeripheralList
    }
    
    func powerMeterManager(didUpdateCadence cadence: Int) {
        dataMap[.cadence] = cadence
    }
}

extension PeripheralViewModel: CadenceSensorManagerDelegate {
    func cadenceSensorManager(didDisconnect peripheral: Peripheral) {
        dataMap[.cadence] = 0
    }
    
    func cadenceSensorManager(didUpdateCadence cadence: Int) {
        cadenceFromSensor = cadence
    }
    
    func cadenceSensorManager(discoveredPeripheralListChanged discoveredPeripheralList: [Peripheral]) {
        self.discoveredCadencePeripherals = discoveredPeripheralList
    }
    
    
}

extension PeripheralViewModel: SpeedSensorManagerDelegate {
    func speedSensorManager(didDisconnect peripheral: Peripheral) {
        dataMap[.speed] = 0.0
    }
    
    func speedSensorManager(didUpdateRpm rpm: Int) {
        let mph = 0.0013079864 * Double(rpm) * 60.0
        // 0.0013079864 circumference of 700x25c wheel in miles
        speedFromSensor = mph
    }
    
    func speedSensorManager(discoveredPeripheralListChanged discoveredPeripheralList: [Peripheral]) {
        self.discoveredSpeedPeripherals = discoveredPeripheralList
    }
}


// MARK: - ActivityDelegate

extension PeripheralViewModel: ActivityDelegate {
    func activity(activityStatusDidChange status: ActivityStatus) {
        self.activityStatus = status
    }
    
    func activity(activityDidUpdate activitySnapshot: ActivitySnapShot, lapSnapshot: LapSnapshot) {
        dataMap[.time] = activitySnapshot.time
        dataMap[.distance] = activitySnapshot.distance
        dataMap[.elevationGain] = activitySnapshot.elevationGain
        dataMap[.avgPower] = activitySnapshot.avgPower
        dataMap[.avgSpeed] = activitySnapshot.avgSpeed
        dataMap[.avgHeartRate] = activitySnapshot.avgHeartRate
        
        dataMap[.lapTime] = lapSnapshot.lapTime
        dataMap[.lapPower] = lapSnapshot.lapPower
        
        print(dataMap[.elevationGain])
    }
    
    func getPower() -> Int {
        return dataMap[.power] as? Int ?? 0
    }
    
    func getHeartRate() -> Int {
        return dataMap[.heartRate] as? Int ?? 0
    }
    
    func getSpeed() -> Double {
        return dataMap[.speed] as? Double ?? 0.0
    }
    
    func getCadence() -> Int {
        return dataMap[.cadence] as? Int ?? 0
    }
    
    func getAltitude() -> Double {
        return dataMap[.altitude] as? Double ?? 0.0
    }
    
    func getLocationCoordinate() -> CLLocationCoordinate2D? {
        return location?.coordinate
    }
}

// MARK: - LocationManagerObserver

extension PeripheralViewModel: LocationManagerObserver {
    func locationManager(didUpdateLocation location: CLLocation) {
        self.location = location
    }
    
    func locationManager(didUpdateSpeed mph: Double) {
        dataMap[.speed] = mph
    }
    
}

// MARK: - AltitudeManagerObserver

extension PeripheralViewModel: AltitudeManagerObserver {
    func altitudeManager(didUpdateAbsoluteAltitude feet: Double) {
        dataMap[.altitude] = feet
    }
    
    func altitudeManager(didUpdateGradePercentage grade: Int) {
        dataMap[.grade] = grade
    }
}


