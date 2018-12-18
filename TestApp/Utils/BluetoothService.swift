//
//  BluetoothService.swift
//  BT-Controller-App
//
//  Created by Chris Sherwin on 18/12/2018.
//  Copyright © 2018 Chris Sherwin. All rights reserved.
//

import Foundation
import CoreBluetooth

class BluetoothService: NSObject, CBCentralManagerDelegate {
    
    var centralMgr: CBCentralManager!
    
    /*
     bluetooth devices
     
     micro:bit
     centralManager [<CBPeripheral: 0x14663370, identifier = 7AA8D89D-7157-4F26-B702-61F92007386C, name = BBC micro:bit [pepep], state = disconnected>]
     
     rpi
     
     */
    
    override init() {
        super.init()
        
        centralMgr = CBCentralManager(delegate: self, queue: nil, options:nil)
    }
    
    func scanForPeripherals() -> Void {
        centralMgr.scanForPeripherals(withServices: nil, options: nil)
    }
    
    //MARK: CBCentralManagerDelegate methods
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        let up = central.state == CBManagerState.poweredOn
        print("centralManagerDidUpdateState [\(up)]")
    }
    
    func centralManager(_ central: CBCentralManager,
                                 didDiscover peripheral: CBPeripheral,
                                 advertisementData: [String : Any],
                                 rssi RSSI: NSNumber) {
        print("centralManager [\(peripheral.debugDescription)]")
    }
}
