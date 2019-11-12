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
    var caller: BluetoothServiceDelegate?
    //    var mgrStateDelegate: (_: String) -> Void
    var knownPeripherals: [CBPeripheral] = []
    var connectedPeripheral: CBPeripheral?
    var matrixCharacteristic: CBCharacteristic?
    var uartRxCharacteristic: CBCharacteristic?
    var eventWriteCharacteristic: CBCharacteristic?
    
    let uuidMicrobit: UUID! = UUID(uuidString: "7AA8D89D-7157-4F26-B702-61F92007386C")
    let mbLedService: String = "E95DD91D-251D-470A-A062-FA1922DFA9A8"
    let mbLedScrollCharc: String = "E95D93EE-251D-470A-A062-FA1922DFA9A8"
    let mbLedMatrixCharc: String = "E95D7B77-251D-470A-A062-FA1922DFA9A8"
    
    let mbEventService: String = "E95D93AF-251D-470A-A062-FA1922DFA9A8"
    // characteristics discovered for service: E95D93AF-251D-470A-A062-FA1922DFA9A8 [4]
    // E95D9775-251D-470A-A062-FA1922DFA9A8: read, notify
    let mbEventCharcWrite: String = "E95D5404-251D-470A-A062-FA1922DFA9A8" //: write, writeWithoutResponse
    // E95D23C4-251D-470A-A062-FA1922DFA9A8: write
    // E95DB84C-251D-470A-A062-FA1922DFA9A8: read, notify
    
    let mbUARTService: String =  "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
    let mbUartTxCharc: String =  "6E400002-B5A3-F393-E0A9-E50E24DCCA9E"
    let mbUartRxCharc: String =  "6E400003-B5A3-F393-E0A9-E50E24DCCA9E"
    
    let uuidRpiBluezTest: UUID! = UUID(uuidString: "870974B0-02AB-43D1-A524-AAB9D3C53E5B")
    
    /*
     bluetooth devices
     
     micro:bit
     UUID:      7AA8D89D-7157-4F26-B702-61F92007386C
     service:   E95D93AF-251D-470A-A062-FA1922DFA9A8
     
     rpi
     bluez test advertisement: 870974B0-02AB-43D1-A524-AAB9D3C53E5B
     */
    
    //    init(delegate: (CBManagerState) -> Void) {
    //    init(mgrStateDelegate: @escaping (_: String) -> Void) {
    //        self.mgrStateDelegate = mgrStateDelegate
    init(delegate: BluetoothServiceDelegate) {
        self.caller = delegate
        super.init()
        
        centralMgr = CBCentralManager(delegate: self, queue: nil, options:nil)
    }
    
    
    func scanForPeripherals() -> Void {
        centralMgr.scanForPeripherals(withServices: nil, options: nil)
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
    
    //    func connect(peripheral: CBPeripheral) -> Void {
    //        centralMgr.connect(peripheral)
    //    }
    
    //MARK: CBCentralManagerDelegate methods
    
    // Connect, Disconnect, etc
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("centralManagerDidUpdateState [\(getCBManagerState(state: central.state))]")
        self.caller!.updateManagerState(state: getCBManagerState(state: central.state))
    }
    
    // Called with scan results
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        print("centralManager didDiscover [\(peripheral.debugDescription)]")
    }
    
    // Called on connect success
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("centralManager didConnect [\(peripheral.name ?? ""), \(getPeripheralState(state: peripheral.state))]")
        self.connectedPeripheral = peripheral
        caller!.updatePeripheralState(uuid: peripheral.identifier, state: peripheral.state)
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    // Called on connect failure
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("centralManager didFailToConnect [\(error!)]")
        //        caller.updatePeripheralState(uuid: peripheral.identifier, state: peripheral.state)
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
            print("\(cha.uuid.uuidString): \(self.getCharcProp(props: cha.properties))")
            //            peripheral.discoverDescriptors(for: cha)
            
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
            else if cha.uuid.uuidString == mbLedScrollCharc {
                //let encString = Array("HELLO IPHONE!".utf8)
                //peripheral.writeValue(Data(bytes: encString), for: cha, type: CBCharacteristicWriteType.withResponse)
            }
            else if cha.uuid.uuidString == mbLedMatrixCharc {
                self.matrixCharacteristic = cha
            }
            else if cha.uuid.uuidString == mbUartRxCharc {
                self.uartRxCharacteristic = cha
            }
            else if cha.uuid.uuidString == mbEventCharcWrite {
                self.eventWriteCharacteristic = cha
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
            caller?.updateReadValue(service: characteristic.service, characteristic: characteristic, value: str)
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
    
    func getCharcProp(props: CBCharacteristicProperties) -> String {
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
    
    func sendMatrixIcon(icon: [UInt8]) {
        print("sendMatrixIcon [\(icon)]")
        if let cha = self.matrixCharacteristic {
            self.connectedPeripheral!.writeValue(
                Data(bytes: icon),
                for: cha,
                type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    func sendUartValue(value: String) {
        print("sendUartValue [\(value)]")
        if let cha = self.uartRxCharacteristic {
            let encString = Array("\(value):".utf8)
            self.connectedPeripheral!.writeValue(
                Data(bytes: encString),
                for: cha,
                type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    func sendEvent(code: UInt16, value: UInt16) {
        print("sendEvent [\(code), \(value)]")
        if let cha = self.eventWriteCharacteristic {
            let data = convertUint16ToByteArray(int: code) + convertUint16ToByteArray(int: value)
            self.connectedPeripheral!.writeValue(
                Data(bytes: data),
                for: cha,
                type: CBCharacteristicWriteType.withResponse)
        }
    }
    
    func convertUint16ToByteArray(int: UInt16) -> [UInt8] {
        var le = int.littleEndian
        let bytes = withUnsafeBytes(of: &le) { Array($0) }
        return bytes
    }
}
/*
 centralManagerDidUpdateState [true]
 retrievePeripheral [870974B0-02AB-43D1-A524-AAB9D3C53E5B]
 retrievePeripheral [raspberrypi, disconnected]
 centralManager didConnect [<CBPeripheral: 0x16640700, identifier = 870974B0-02AB-43D1-A524-AAB9D3C53E5B, name = raspberrypi, state = connected>]
 peripheral discovered [services: 3]
 180D: <CBService: 0x1656a250, isPrimary = YES, UUID = Heart Rate>
 characteristics discovered for service: Heart Rate [3]
 2A37: notify
 2A38: read
 2A39: write
 readValue for characteristic [2A38, value: 1]
 2018-12-31 16:46:35.702769+0100 BT-Controller-App[720:275258] [CoreBluetooth] WARNING: The delegate for <CBPeripheral: 0x16640700, identifier = 870974B0-02AB-43D1-A524-AAB9D3C53E5B, name = raspberrypi, state = connected> does not implement -[peripheral:didModifyServices:]
 2018-12-31 16:46:35.762812+0100 BT-Controller-App[720:275258] [CoreBluetooth] WARNING: The delegate for <CBPeripheral: 0x16640700, identifier = 870974B0-02AB-43D1-A524-AAB9D3C53E5B, name = raspberrypi, state = connected> does not implement -[peripheral:didModifyServices:]
 2018-12-31 16:46:35.822833+0100 BT-Controller-App[720:275258] [CoreBluetooth] WARNING: The delegate for <CBPeripheral: 0x16640700, identifier = 870974B0-02AB-43D1-A524-AAB9D3C53E5B, name = raspberrypi, state = connected> does not implement -[peripheral:didModifyServices:]
 */
/*
 Response from Micro:bit
 
 centralManagerDidUpdateState [true]
 retrievePeripherals [BBC micro:bit [pepep], CBPeripheralState]
 centralManager didConnect [<CBPeripheral: 0x1461c920, identifier = 7AA8D89D-7157-4F26-B702-61F92007386C, name = BBC micro:bit [pepep], state = connected>]
 peripheral discovered [services: 4]
 <CBService: 0x1463d9d0, isPrimary = YES, UUID = E95D93B0-251D-470A-A062-FA1922DFA9A8>
 <CBService: 0x1463dca0, isPrimary = YES, UUID = E97DD91D-251D-470A-A062-FA1922DFA9A8>
 <CBService: 0x14554420, isPrimary = YES, UUID = Device Information>
 <CBService: 0x1451b4d0, isPrimary = YES, UUID = E95D93AF-251D-470A-A062-FA1922DFA9A8>
 characteristics discovered for service: E95D93B0-251D-470A-A062-FA1922DFA9A8 [1]
 <CBCharacteristic: 0x14558a60, UUID = E95D93B1-251D-470A-A062-FA1922DFA9A8, properties = 0xA, value = (null), notifying = NO>
 characteristics discovered for service: E97DD91D-251D-470A-A062-FA1922DFA9A8 [1]
 <CBCharacteristic: 0x1451d190, UUID = E97D3B10-251D-470A-A062-FA1922DFA9A8, properties = 0x14, value = (null), notifying = NO>
 characteristics discovered for service: Device Information [3]
 <CBCharacteristic: 0x1463c2f0, UUID = Model Number String, properties = 0x2, value = (null), notifying = NO>
 <CBCharacteristic: 0x1463ca60, UUID = Serial Number String, properties = 0x2, value = (null), notifying = NO>
 <CBCharacteristic: 0x1463caa0, UUID = Firmware Revision String, properties = 0x2, value = (null), notifying = NO>
 characteristics discovered for service: E95D93AF-251D-470A-A062-FA1922DFA9A8 [4]
 <CBCharacteristic: 0x1463e560, UUID = E95D9775-251D-470A-A062-FA1922DFA9A8, properties = 0x12, value = (null), notifying = NO>
 <CBCharacteristic: 0x1463e630, UUID = E95D5404-251D-470A-A062-FA1922DFA9A8, properties = 0xC, value = (null), notifying = NO>
 <CBCharacteristic: 0x1463e670, UUID = E95D23C4-251D-470A-A062-FA1922DFA9A8, properties = 0x8, value = (null), notifying = NO>
 <CBCharacteristic: 0x1463cb20, UUID = E95DB84C-251D-470A-A062-FA1922DFA9A8, properties = 0x12, value = (null), notifying = NO>
 <CBDescriptor: 0x14556570, UUID = Client Characteristic Configuration, value = (null)>
 <CBDescriptor: 0x1463e490, UUID = Client Characteristic Configuration, value = (null)>
 <CBDescriptor: 0x145181a0, UUID = Client Characteristic Configuration, value = (null)>
 
 */
