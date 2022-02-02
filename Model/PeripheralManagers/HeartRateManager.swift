//
//  HeartRateManager.swift
//  BikeComputer
//
//  Created by Allen Liang on 8/25/21.
//

import Foundation
import CoreBluetooth

class HeartRateManager: PeripheralManager {
    var delegate: HeartRateManagerDelegate
    
    init(delegate: HeartRateManagerDelegate) {
        self.delegate = delegate
        super.init()
        self.lastConnectedKey = "lastConnectedHeartRate"
        self.serviceUUID = CBUUID(string: "0x180D")
        self.characteristicUUIDs = [CBUUID(string: "2A37")]
    }
    
    override func discoveredPeripheralListChanged() {
        delegate.heartRateManager(discoveredPeripheralListChanged: discoveredPeripherals)
    }
    
    override func triggerConnectedHUD(name: String?) {
        GlobalObject.shared.show(systemImage: "heart", message: "Connected to \(name ?? "Heart Rate Sensor")")
    }
    
    override func triggerDisconnectHUD(name: String?) {
        GlobalObject.shared.show(systemImage: "heart", message: "Disconnected \(name ?? "Heart Rate Sensor")")
    }
    
    override func handlePeripheralDidDisconnect(peripheral: Peripheral) {
        delegate.heartRateManager(didDisconnect: peripheral)
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
            let bpm = heartRate(from: characteristic)
            delegate.heartRateManager(heartRateDidUpdate: bpm)
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    
    
    private func heartRate(from characteristic: Characteristic) -> Int {
        guard let characteristicData = characteristic.value else { return -1 }
        let byteArray = [UInt8](characteristicData)
        let firstByte = byteArray[0]
        let firstBitValue = firstByte & 0x01
        if firstBitValue == 0 {
            return Int(byteArray[1])
        } else {
            return (Int(byteArray[1]) << 8) + Int(byteArray[2])
        }
    }
}

protocol HeartRateManagerDelegate {
    func heartRateManager(didDisconnect peripheral: Peripheral)
    func heartRateManager(heartRateDidUpdate heartRate: Int)
    func heartRateManager(discoveredPeripheralListChanged discoveredPeripheralList: [Peripheral])
}
