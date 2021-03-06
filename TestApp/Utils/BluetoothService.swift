//
//  BluetoothService.swift
//  BT-Controller-App
//
//  Created by Chris Sherwin on 18/12/2018.
//  Copyright © 2018 Chris Sherwin. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothService: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralMgr: CBCentralManager!
    var cbSvcDelegate: BluetoothServiceDelegate?
    //    var mgrStateDelegate: (_: String) -> Void
    var knownPeripherals: [CBPeripheral] = []
    var connectedPeripheral: CBPeripheral?
    
    var mbLedScrollCharacteristic: CBCharacteristic?
    var mbLedMatrixCharacteristic: CBCharacteristic?
    var mbUartWriteCharacteristic: CBCharacteristic?
    var mbUartReadCharacteristic: CBCharacteristic?
    var mbEventWriteCharacteristic: CBCharacteristic?
    var mbEventReadCharacteristic: CBCharacteristic?
    
    let uuidMicrobit: UUID! = UUID(uuidString: "7AA8D89D-7157-4F26-B702-61F92007386C")
    
    let mbLedServiceUUID: CBUUID =  CBUUID(string: "E95DD91D-251D-470A-A062-FA1922DFA9A8")
    let mbLedScrollCharcUUID: CBUUID =  CBUUID(string: "E95D93EE-251D-470A-A062-FA1922DFA9A8")
    let mbLedMatrixCharcUUID: CBUUID =  CBUUID(string: "E95D7B77-251D-470A-A062-FA1922DFA9A8")
    
    let mbEventServiceUUID: CBUUID =  CBUUID(string: "E95D93AF-251D-470A-A062-FA1922DFA9A8")
    let mbEventReadCharcUUID: CBUUID =  CBUUID(string: "E95D9775-251D-470A-A062-FA1922DFA9A8") //: read, notify
    let mbEventWriteCharcUUID: CBUUID =  CBUUID(string: "E95D5404-251D-470A-A062-FA1922DFA9A8") //: write, writeWithoutResponse
    
    let mbUARTServiceUUID: CBUUID =  CBUUID(string: "6E400001-B5A3-F393-E0A9-E50E24DCCA9E")
    let mbUartWriteCharcUUID: CBUUID =  CBUUID(string: "6E400002-B5A3-F393-E0A9-E50E24DCCA9E")
    let mbUartReadCharcUUID: CBUUID =  CBUUID(string: "6E400003-B5A3-F393-E0A9-E50E24DCCA9E")
    
    let uuidRpiBluezTest: UUID! = UUID(uuidString: "870974B0-02AB-43D1-A524-AAB9D3C53E5B")
    
    /*
     bluetooth devices
     
     micro:bit
     UUID:      7AA8D89D-7157-4F26-B702-61F92007386C
     service:   E95D93AF-251D-470A-A062-FA1922DFA9A8
     
     rpi
     bluez test advertisement: 870974B0-02AB-43D1-A524-AAB9D3C53E5B
     */
    
    init(delegate: BluetoothServiceDelegate) {
        self.cbSvcDelegate = delegate
        super.init()
        
        centralMgr = CBCentralManager(delegate: self, queue: nil, options: nil)
    }
    
    func scanForPeripherals() -> Void {
        print("Scanning..")
        self.cbSvcDelegate?.updateScanningState(isScanning: true)
        centralMgr.scanForPeripherals(withServices: nil, options: nil)
        
        Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { (timer) in
            self.stopScanning()
        }
    }
    
    func stopScanning() -> Void {
        print("Stop scanning")
        self.cbSvcDelegate?.updateScanningState(isScanning: false)
        centralMgr.stopScan()
    }
    
    func retrievePeripheral(uuid: UUID) -> Void {
        print("retrievePeripheral [\(uuid.debugDescription)]")
        
        knownPeripherals = centralMgr.retrievePeripherals(withIdentifiers: [uuid])
        
        if knownPeripherals.count != 1 {
            print("Incorrect number of peripherals [\(knownPeripherals.count)] found for uuid [\(uuid.debugDescription)]")
        } else {
            if let p = knownPeripherals.first {
                print("retrievePeripheral [\(p.name ?? "")]")//, \(self.getPeripheralState(state: p.state))]")
                centralMgr.connect(p)
            } else {
                print("retrievePeripheral Could not retrieve []")
            }
        }
    }
    
    //MARK: CBCentralManagerDelegate methods
    
    // Connect, Disconnect, etc
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState [\(getCBManagerState(state: central.state))]")
        self.cbSvcDelegate!.updateManagerState(state: getCBManagerState(state: central.state))
    }
    
    // Called with scan results
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        if let name = peripheral.name {
            print("centralManager didDiscover \(name) [\(peripheral.debugDescription)]")
        }
    }
    
    // Called on connect success
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("centralManager didConnect [\(peripheral.name ?? ""), \(getPeripheralState(state: peripheral.state))]")
        self.connectedPeripheral = peripheral
        self.cbSvcDelegate!.updatePeripheralState(uuid: peripheral.identifier, state: peripheral.state)
        
        peripheral.delegate = self
        peripheral.discoverServices([mbEventServiceUUID])
    }
    
    // Called on connect failure
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("centralManager didFailToConnect [\(error!)]")
        //        caller.updatePeripheralState(uuid: peripheral.identifier, state: peripheral.state)
    }
    
    // Called on disconnection
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("centralManager didDisconnect [\(peripheral.name ?? ""), \(getPeripheralState(state: peripheral.state))]")
        self.connectedPeripheral = nil
        self.cbSvcDelegate!.updatePeripheralState(uuid: peripheral.identifier, state: peripheral.state)
    }
    
    //MARK: CBPeripheralDelegate methods
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let err = error {
            print("peripheral service discovery [error: \(err.localizedDescription)]")
            return
        }
        
        print("peripheral services discovered [\(peripheral.services!.count)]")
        for service in peripheral.services! {
            print("service: \(service.uuid.uuidString)")//", \(service.debugDescription)")
            //            if service.uuid.uuidString == "180D" || service.uuid.uuidString == "180A" {
            //                print("\(service.uuid.uuidString): \(service.debugDescription)")
            peripheral.discoverCharacteristics(nil, for: service)
            //            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let err = error {
            print("peripheral charachteristic discovery [service: \(service.uuid), error: \(err.localizedDescription)]")
            return
        }
        
        print("characteristics discovered for service: \(service.uuid) [\(service.characteristics!.count)]")
        for cha in service.characteristics! {
//            print("\(cha.uuid.uuidString): \(self.getCharcUUIDProp(props: cha.properties))")
            
            // RPi
            if cha.uuid.uuidString == "2A38" {
                peripheral.readValue(for: cha)
            } else if cha.uuid.uuidString == "2A3A" {
                peripheral.writeValue(Data(bytes: [0x4]), for: cha, type: CBCharacteristicWriteType.withResponse)
            } else if cha.uuid.uuidString == "2A39" {
                let encString = Array("F".utf8)
                peripheral.writeValue(Data(bytes: encString), for: cha, type: CBCharacteristicWriteType.withResponse)
            }
            // Micro:Bit
            else {
                switch cha.uuid {
                case mbLedScrollCharcUUID:
                    self.mbLedScrollCharacteristic = cha
                    print("Characteristic found [\(getCharacteristicDescription(cha))]")
                case mbLedMatrixCharcUUID:
                    self.mbLedMatrixCharacteristic = cha
                    print("Characteristic found [\(getCharacteristicDescription(cha))]")
                case mbUartReadCharcUUID:
                    self.mbUartWriteCharacteristic = cha
                    print("Characteristic found [\(getCharacteristicDescription(cha))]")
                case mbEventWriteCharcUUID:
                    self.mbEventWriteCharacteristic = cha
                    print("Characteristic found [\(getCharacteristicDescription(cha))]")
                default:
                    print("Characteristic ignored [\(getCharacteristicDescription(cha))]")
                }
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let err = error {
            print("peripheral characteristic didUpdateValueFor [\(characteristic.uuid), error: \(err.localizedDescription)]")
        }
        
        if let value = characteristic.value {
            let str = value.map({(d) in String(d)}).joined(separator: ",")
            print("readValue for characteristic [\(characteristic.uuid), value: \(str)]")
            self.cbSvcDelegate?.updateReadValue(service: characteristic.service, characteristic: characteristic, value: str)
        } else {
            print("readValue No value for characteristic [\(characteristic.uuid)]")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if let err = error {
            print("descriptor discovery [service: \(characteristic.uuid), error: \(err.localizedDescription)]")
            return
        }
        
        for desc in characteristic.descriptors! {
            print("    \(desc.debugDescription)")
        }
    }
    
    func sendMatrixIcon(icon: [UInt8]) {
        print("sendMatrixIcon [\(icon)]")
        if let cha = self.mbLedMatrixCharacteristic {
            self.connectedPeripheral!.writeValue(
                Data(bytes: icon),
                for: cha,
                type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    func sendUartValue(value: String) {
        print("sendUartValue [\(value)]")
        if let cha = self.mbUartWriteCharacteristic {
            let encString = Array("\(value):".utf8)
            self.connectedPeripheral!.writeValue(
                Data(bytes: encString),
                for: cha,
                type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    func sendEvent(code: UInt16, value: UInt16) {
        if let cha = self.mbEventWriteCharacteristic {
            let data = convertUint16ToByteArray(int: code) + convertUint16ToByteArray(int: value)
            if let periph = self.connectedPeripheral {
                periph.writeValue(
                    Data(bytes: data),
                    for: cha,
                    type: CBCharacteristicWriteType.withResponse)
            } else {
                print("sendEvent Unable to send to disconnected peripheral")
            }
        }
    }
    
    func convertUint16ToByteArray(int: UInt16) -> [UInt8] {
        var le = int.littleEndian
        let bytes = withUnsafeBytes(of: &le) { Array($0) }
        return bytes
    }

    //MARK: Functions
    
    func getCBManagerState(state: CBManagerState) -> String {
        switch state {
        case .poweredOff: return "Bluetooth Disabled"
        case .poweredOn: return "Ready to Connect"
        case .resetting: return "Resetting"
        case .unauthorized: return "Unauthorized"
        case .unknown: return "Unknown"
        case .unsupported: return "Unsupported"
        }
    }
    
    func getPeripheralState(state: CBPeripheralState) -> String {
        switch state {
        case .connecting: return "Connecting"
        case .connected: return "Connected"
        case .disconnecting: return "Disconnecting"
        case .disconnected: return "Disconnected"
        }
    }
    
    func getCharacteristicDescription(_ characteristic: CBCharacteristic) -> String {
        "\(characteristic.uuid.uuidString): \(self.getCharcUUIDProp(props: characteristic.properties))"
    }
    
    func getCharcUUIDProp(props: CBCharacteristicProperties) -> String {
        var propLabels: [String] = []
        if props.contains(CBCharacteristicProperties.read) {
            propLabels.append("read")
        }
        if props.contains(CBCharacteristicProperties.write) {
            propLabels.append("write")
        }
        if props.contains(CBCharacteristicProperties.writeWithoutResponse) {
            propLabels.append("writeWithoutResponse")
        }
        if props.contains(CBCharacteristicProperties.notify) {
            propLabels.append("notify")
        }
        return propLabels.joined(separator: ", ")
    }
}
