//
//  BluetoothServiceDelegate.swift
//  BT-Controller-App
//
//  Created by Chris Sherwin on 01/01/2019.
//  Copyright © 2019 Chris Sherwin. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol BluetoothServiceDelegate: class {
    
    func updateManagerState(state: String)
    
    func updatePeripheralState(uuid: UUID, state: CBPeripheralState)
    
    func updateReadValue(service: CBService, characteristic: CBCharacteristic, value: String)
    
}
