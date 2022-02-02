//
//  PowerMeterManager.swift
//  BikeComputer
//
//  Created by Allen Liang on 8/25/21.
//

import Foundation
import CoreBluetooth
import UIKit

class PowerMeterManager: PeripheralManager { // TODO: needs to be test before change
    var delegate: PowerMeterManagerDelegate
    private(set) var previousCrankRevolutionCount: UInt16 = 0
    private(set) var previousCrankEvent: UInt16 = 0
    
    init(delegate: PowerMeterManagerDelegate) {
        self.delegate = delegate
        super.init()
        self.lastConnectedKey = "lastConnectedPower"
        self.serviceUUID = CBUUID(string: "0x1818")
        self.characteristicUUIDs = [CBUUID(string: "0x2A63")]
    }
    
    override func discoveredPeripheralListChanged() {
        delegate.powerMeterManager(discoveredPeripheralListChanged: discoveredPeripherals)
    }
    
    override func triggerConnectedHUD(name: String?) {
        GlobalObject.shared.show(systemImage: "bolt.circle", message: "Connected to \(name ?? "Power Meter")")
    }
    
    override func triggerDisconnectHUD(name: String?) {
        GlobalObject.shared.show(systemImage: "bolt.circle", message: "Disconnected \(name ?? "Power Meter")")
    }
    
    override func handlePeripheralDidDisconnect(peripheral: Peripheral) {
        delegate.powerMeterManager(didDisconnect: peripheral)
    }
    
    override func peripheral(_ peripheral: Peripheral, didDiscoverCharacteristicsFor service: Service, error: Error?) {
        guard let characteristics = service.characteristics else { return }
        if service.uuid == serviceUUID {
            for characteristic in characteristics {
                if characteristic.uuid == characteristicUUIDs[0] {
                    peripheral.setNotifyValue(true, for: characteristic)
                    break
                }
            }
        }
    }
    
    override func peripheral(_ peripheral: Peripheral, didUpdateValueFor characteristic: Characteristic, error: Error?) {
        switch characteristic.uuid {
        case characteristicUUIDs[0]:
            readCyclingPowerMeasurementData(from: characteristic)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    //TODO: check array bounds before look up?
    //TODO: power measurement should be sint16 but wouldn't matter if it was stayed uint
    private func readCyclingPowerMeasurementData(from characteristic: Characteristic) {
        guard let characteristicData = characteristic.value else { return }
        let byteArray = [UInt8](characteristicData)
        
        let power = Utility.uInt8ToUint16(byteArray[2], byteArray[3])
        delegate.powerMeterManager(didUpdatePower: Int(power))
        
        
        
        let flags: UInt16 = Utility.uInt8ToUint16(byteArray[0], byteArray[1])
        let crankDataPresent = (flags & 0b100000) != 0
        if !crankDataPresent {
            return
        }
        let pedalPowerBalancePresent = (flags & 0b01) != 0
        let accumulatedTorquePresent = (flags & 0b100) != 0
        let wheelDataPresent = (flags & 0b10000) != 0
        
        var crankRevIndex = 4
        if pedalPowerBalancePresent {
            crankRevIndex += 1
        }
        if accumulatedTorquePresent {
            crankRevIndex += 2
        }
        if wheelDataPresent {
            crankRevIndex += 6
        }
        
        let crankRevCount = Utility.uInt8ToUint16(byteArray[crankRevIndex], byteArray[crankRevIndex+1])
        let crankEvent = Utility.uInt8ToUint16(byteArray[crankRevIndex+2], byteArray[crankRevIndex+3])
        let timeElapsed = crankEvent &- previousCrankEvent
        
        if timeElapsed < 1024 {
            return
        }
        let rpm = Utility.calculateRpm(prevRev: self.previousCrankRevolutionCount, prevTime: self.previousCrankEvent, rev: crankRevCount, time: crankEvent)
        self.previousCrankRevolutionCount = crankRevCount
        self.previousCrankEvent = crankEvent
        
        delegate.powerMeterManager(didUpdateCadence: rpm)
    }
}

protocol PowerMeterManagerDelegate {
    func powerMeterManager(didDisconnect peripheral: Peripheral)
    func powerMeterManager(didUpdatePower power: Int)
    func powerMeterManager(discoveredPeripheralListChanged discoveredPeripheralList: [Peripheral])
    func powerMeterManager(didUpdateCadence cadence: Int)
}
