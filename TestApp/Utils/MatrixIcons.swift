
//
//  Matrix.swift
//  BT-Controller-App
//
//  Created by Chris Sherwin on 09/11/2019.
//  Copyright © 2019 Chris Sherwin. All rights reserved.
//

import Foundation

struct MatrixIcons {
    
    // Each hex value is a row of the microbit LEDs
    // In each row, the LEDs are a bitmap (1,2,4,8,16) so all on is 31 (0x1f)
    static let Neutral: [UInt8] = [0x0,0x0,0x4,0x0,0x0]
    static let ForwardArrow: [UInt8] = [0x4,0xe,0x1f,0x0,0x0]
    static let BackwardArrow: [UInt8] = [0x0,0x0,0x1f,0xe,0x4]
    static let LeftArrow: [UInt8] = [0x4,0xc,0x1c,0xc,0x4]
    static let RightArrow: [UInt8] = [0x4,0x6,0x7,0x6,0x4]
}
