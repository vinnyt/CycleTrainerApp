//
//  PeripheralManager.swift
//  CycleTrainer
//
//  Created by Allen Liang on 12/24/21.
//

import Foundation
import CoreBluetooth

class PeripheralManager: NSObject, PeripheralDelegate {
    var centralManager: CentralManager!
    var lastConnectedKey: String = ""
    var discoveredPeripherals = [Peripheral]()
    var shouldReconnect = false
    var connectedPeripheral: Peripheral?
    var serviceUUID = CBUUID()
    var characteristicUUIDs = [CBUUID]()
    
    init(centralManager: CentralManager = CBCentralManager()) {
        self.centralManager = centralManager
        super.init()
        centralManager.delegate = self
    }
    
    func tryToConnectToLastPeripheral(userDefaults: UserDefaults = UserDefaults.standard) {
        guard let lastConnectedHeartRateUUIDString = userDefaults.string(forKey: lastConnectedKey) else { return }
        let uuid = UUID(uuidString: lastConnectedHeartRateUUIDString)
        let lastConnected = centralManager.retrievePeripherals(withIdentifiers: [uuid!])
        
        guard let peripheral = lastConnected.first else { return }
        discoveredPeripherals.append(peripheral)
        discoveredPeripheralListChanged()
        connectTo(peripheral: peripheral)
    }
    
    func scanForPeripherals() {
        clearDiscoveredPeripheralsList()
        if connectedPeripheral != nil {
            discoveredPeripherals.append(connectedPeripheral!)
            discoveredPeripheralListChanged()
        }
        centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
    }
    
    func clearDiscoveredPeripheralsList() {
        discoveredPeripherals = [Peripheral]()
        discoveredPeripheralListChanged()
    }
    
    func stopScanning() {
        centralManager.stopScan()
    }
    
    func connectTo(peripheral: Peripheral) {
        disconnect()
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
    }
    
    func disconnect() {
        shouldReconnect = false
        if connectedPeripheral != nil {
            centralManager.cancelPeripheralConnection(connectedPeripheral!)
        }
    }
    
    func discoveredPeripheralListChanged() { // subclasses should override
        fatalError()
    }
    
    func triggerConnectedHUD(name: String?) { // subclasses should override
        GlobalObject.shared.show(systemImage: "antenna.radiowaves.left.and.right", message: "Connected To \(name ?? "Sensor")")
    }
    
    func triggerDisconnectHUD(name: String?) { // subclasses should override
        GlobalObject.shared.show(systemImage: "antenna.radiowaves.left.and.right", message: "Disconnect from \(name ?? "Sensor")")
    }
    
    func handlePeripheralDidDisconnect(peripheral: Peripheral) { // subclasses should override
        fatalError()
    }
    
    func setLastConnectedUUIDToUserDefaults(uuidString: String, userDefaults: UserDefaults = UserDefaults.standard) {
        userDefaults.set(uuidString, forKey: lastConnectedKey)
    }
    
    // MARK: - PeripheralDelegate
    
    //subclass should override
    func peripheral(_ peripheral: Peripheral, didUpdateValueFor characteristic: Characteristic, error: Error?) {
        fatalError()
    }
    
    //subclass should override
    func peripheral(_ peripheral: Peripheral, didDiscoverCharacteristicsFor service: Service, error: Error?) {
        fatalError()
    }
    
    func peripheral(_ peripheral: Peripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(characteristicUUIDs, for: service)
        }
    }
    
    // MARK: - PeripheralDelegate Intermediate Functions/bridging functions?
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        self.peripheral(peripheral as Peripheral, didDiscoverServices: error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        self.peripheral(peripheral as Peripheral, didUpdateValueFor: characteristic as Characteristic, error: error)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        self.peripheral(peripheral as Peripheral, didDiscoverCharacteristicsFor: service as Service, error: error)
    }
}

extension PeripheralManager: CentralManagerDelegate {
    func centralManager(_ central: CentralManager, didDisconnectPeripheral peripheral: Peripheral, error: Error?) {
        connectedPeripheral = nil
        triggerDisconnectHUD(name: peripheral.name)
        handlePeripheralDidDisconnect(peripheral: peripheral)
    }
    
    func centralManagerDidUpdateState(_ central: CentralManager) {
        switch central.state {
            case .unknown:
                print("central.state is .unknown")
            case .resetting:
                print("central.state is .resetting")
            case .unsupported:
                print("central.state is .unsupported")
            case .unauthorized:
                print("central.state is .unauthorized")
            case .poweredOff:
                print("central.state is .poweredOff")
            case .poweredOn:
                print("central.state is .poweredOn")
                tryToConnectToLastPeripheral()
            @unknown default:
                print("unknown case")
            }
    }
    
    func centralManager(_ central: CentralManager, didDiscover peripheral: Peripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(where: {$0.identifier.uuidString == peripheral.identifier.uuidString}) {
            discoveredPeripherals.append(peripheral)
            discoveredPeripheralListChanged()
        }
    
    }
    
    func centralManager(_ central: CentralManager, didConnect peripheral: Peripheral) {
        setLastConnectedUUIDToUserDefaults(uuidString: peripheral.identifier.uuidString)
        connectedPeripheral = peripheral
        peripheral.delegate = self
        shouldReconnect = true
        centralManager.stopScan()
        triggerConnectedHUD(name: peripheral.name)
        peripheral.discoverServices([serviceUUID])
    }
    
    
    
    // MARK: - CentralManagerDelegate Intermediate Functions/bridging functions?
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
            centralManagerDidUpdateState(central as CentralManager)
        }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
            centralManager(central as CentralManager,
                           didDiscover: peripheral as Peripheral,
                           advertisementData: advertisementData,
                           rssi: RSSI)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        centralManager(central as CentralManager, didConnect: peripheral as Peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        centralManager(central as CentralManager, didDisconnectPeripheral: peripheral as Peripheral, error: error)
    }
}














protocol CentralManager: NSObjectProtocol {
    var delegate: CBCentralManagerDelegate? { get set }
    var state: CBManagerState { get }
    
    func connect(_ peripheral: Peripheral, options: [String : Any]?)
    func scanForPeripherals(withServices serviceUUIDs: [CBUUID]?, options: [String : Any]?)
    func stopScan()
    func cancelPeripheralConnection(_ peripheral: Peripheral)
    func retrievePeripherals(withIdentifiers: [UUID]) -> [Peripheral]

}


extension CBCentralManager: CentralManager {
    func retrievePeripherals(withIdentifiers: [UUID]) -> [Peripheral] {
        let peripherals: [CBPeripheral] = retrievePeripherals(withIdentifiers: withIdentifiers)
        return peripherals as [Peripheral]
    }
    
    func connect(_ peripheral: Peripheral, options: [String : Any]?) {
        guard let peripheral = peripheral as? CBPeripheral else { fatalError() }
        connect(peripheral)
    }
    
    func cancelPeripheralConnection(_ peripheral: Peripheral) {
        guard let peripheral = peripheral as? CBPeripheral else { fatalError() }
        cancelPeripheralConnection(peripheral)
    }
}

protocol CentralManagerDelegate: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CentralManager)
    func centralManager(_ central: CentralManager, didDiscover peripheral: Peripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
    func centralManager(_ central: CentralManager, didConnect peripheral: Peripheral)
    func centralManager(_ central: CentralManager, didDisconnectPeripheral peripheral: Peripheral, error: Error?)
}

extension CentralManagerDelegate {
    // CBCentralManagerDelegate exposes objc, will not work because concrete implementations won't translate into objc
    // will work in swift libraries
    func centralManagerDidUpdateState(_ central: CentralManager) {
        centralManagerDidUpdateState(central as CentralManager)
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
            centralManager(central as CentralManager,
                           didDiscover: peripheral as Peripheral,
                           advertisementData: advertisementData,
                           rssi: RSSI)
    }
}






protocol Peripheral: NSObjectProtocol {
    var name: String? { get }
    var identifier: UUID { get }
    var delegate: CBPeripheralDelegate? { get set }
    var services: [CBService]? { get }
    
    func discoverServices(_ serviceUUIDs: [CBUUID]?)
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: Service)
    func setNotifyValue(_ enabled: Bool, for characteristic: Characteristic)
}

extension CBPeripheral: Peripheral {
    func discoverCharacteristics(_ characteristicUUIDs: [CBUUID]?, for service: Service) {
        guard let service = service as? CBService else { fatalError() }
        discoverCharacteristics(characteristicUUIDs, for: service)
    }
    
    func setNotifyValue(_ enabled: Bool, for characteristic: Characteristic) {
        guard let characteristic = characteristic as? CBCharacteristic else { fatalError() }
        setNotifyValue(enabled, for: characteristic)
    }
}

protocol PeripheralDelegate: CBPeripheralDelegate {
    func peripheral(_ peripheral: Peripheral, didDiscoverServices error: Error?)
    func peripheral(_ peripheral: Peripheral, didUpdateValueFor characteristic: Characteristic, error: Error?)
    func peripheral(_ peripheral: Peripheral, didDiscoverCharacteristicsFor service: Service, error: Error?)
}

protocol Service {
    var characteristics: [CBCharacteristic]? { get }
    var uuid: CBUUID { get }
}



extension CBService: Service {
    
}

protocol Characteristic {
    var uuid: CBUUID { get }
    var value: Data? { get }
}

extension CBCharacteristic: Characteristic {
    
}
