//
//  CadenceSensorManager.swift
//  CycleTrainer
//
//  Created by Allen Liang on 12/23/21.
//

import Foundation
import CoreBluetooth

class CadenceSensorManager: PeripheralManager {
    var delegate: CadenceSensorManagerDelegate
    private var previousCrankRevolutionCount: UInt16 = 0
    private var previousCrankEvent: UInt16 = 0
    
    init(delegate: CadenceSensorManagerDelegate) {
        self.delegate = delegate
        super.init()
        self.lastConnectedKey = "lastConnectedCadenceSensor"
        self.serviceUUID = CBUUID(string: "0x1816")
        self.characteristicUUIDs = [CBUUID(string: "0x2A5B")]
    }
    
    override func discoveredPeripheralListChanged() {
        delegate.cadenceSensorManager(discoveredPeripheralListChanged: discoveredPeripherals)
    }
    
    override func triggerConnectedHUD(name: String?) {
        GlobalObject.shared.show(systemImage: "lasso", message: "Connected to \(name ?? "Cadence Sensor")")
    }
    
    override func triggerDisconnectHUD(name: String?) {
        GlobalObject.shared.show(systemImage: "lasso", message: "Disconnected \(name ?? "Cadence Sensor")")
    }
    
    override func handlePeripheralDidDisconnect(peripheral: Peripheral) {
        delegate.cadenceSensorManager(didDisconnect: peripheral)
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
            readCadence(from: characteristic)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    private func readCadence(from characteristic: Characteristic) {
        guard let characteristicData = characteristic.value else { return }
        let byteArray = [UInt8](characteristicData)
        
        let flags = byteArray[0]
        let wheelFlagPresent = (flags & 0b01) != 0
        let crankFlagPresent = (flags & 0b10) != 0
        
        if !crankFlagPresent {
             return
        }
        var crankRevIndex = 1
        if wheelFlagPresent {
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
        self.previousCrankEvent = crankRevCount
        
        delegate.cadenceSensorManager(didUpdateCadence: rpm)
        
    }
}

protocol CadenceSensorManagerDelegate {
    func cadenceSensorManager(didDisconnect peripheral: Peripheral)
    func cadenceSensorManager(didUpdateCadence cadence: Int)
    func cadenceSensorManager(discoveredPeripheralListChanged discoveredPeripheralList: [Peripheral])
}
