//
//  SpeedSensorManager.swift
//  CycleTrainer
//
//  Created by Allen Liang on 12/23/21.
//

import Foundation
import CoreBluetooth

class SpeedSensorManager: PeripheralManager {
    var delegate: SpeedSensorManagerDelegate
    private var previousWheelRevolutionCount: UInt32 = 0
    private var previousWheelEvent: UInt16 = 0
    
    init(delegate: SpeedSensorManagerDelegate) {
        self.delegate = delegate
        super.init()
        self.lastConnectedKey = "lastConnectedSpeedSensor"
        self.serviceUUID = CBUUID(string: "0x1816")
        self.characteristicUUIDs = [CBUUID(string: "0x2A5B")]
    }
    
    override func discoveredPeripheralListChanged() {
        delegate.speedSensorManager(discoveredPeripheralListChanged: discoveredPeripherals)
    }
    
    override func triggerConnectedHUD(name: String?) {
        GlobalObject.shared.show(systemImage: "speedometer", message: "Connected to \(name ?? "Speed Sensor")")
    }
    
    override func triggerDisconnectHUD(name: String?) {
        GlobalObject.shared.show(systemImage: "heart", message: "Disconnected \(name ?? "Speed Sensor")")
    }
    
    override func handlePeripheralDidDisconnect(peripheral: Peripheral) {
        delegate.speedSensorManager(didDisconnect: peripheral)
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
            readWheelRevolutions(from: characteristic)
            break
        default:
            print("Unhandled Characteristic UUID: \(characteristic.uuid)")
        }
    }
    
    private func readWheelRevolutions(from characteristic: Characteristic) {
        guard let characteristicData = characteristic.value else { return }
        let byteArray = [UInt8](characteristicData)
        
        let flags = byteArray[0]
        let wheelFlagPresent = (flags & 0b01) != 0
        if !wheelFlagPresent {
             return
        }
        
        let wheelRevCount = Utility.uInt8ToUInt32(byteArray[1], byte2: byteArray[2], byte3: byteArray[3], byte4: byteArray[4])
        let wheelEvent = Utility.uInt8ToUint16(byteArray[5], byteArray[6])
        let timeElapsed = wheelEvent &- previousWheelEvent
        
        if timeElapsed < 1024 {
            return
        }
        let rpm = Utility.calculateRpm(prevRev: self.previousWheelRevolutionCount, prevTime: self.previousWheelEvent, rev: wheelRevCount, time: wheelEvent)
        self.previousWheelRevolutionCount = wheelRevCount
        self.previousWheelEvent = wheelEvent
        
        delegate.speedSensorManager(didUpdateRpm: rpm)
    }
}

protocol SpeedSensorManagerDelegate {
    func speedSensorManager(didDisconnect peripheral: Peripheral)
    func speedSensorManager(didUpdateRpm rpm: Int)
    func speedSensorManager(discoveredPeripheralListChanged discoveredPeripheralList: [Peripheral])
}
