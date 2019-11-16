//
//  MicroBitEvents.swift
//  BT-Controller-App
//
//  Created by Chris Sherwin on 10/11/2019.
//  Copyright © 2019 Chris Sherwin. All rights reserved.
//

import Foundation

struct MicroBitEvents {
    static let MICROBIT_EVENT_SVC_FWD_BWD: UInt16 = 2001
    static let MICROBIT_EVENT_SVC_LFT_RGT: UInt16 = 2002

    static let NEUTRAL: UInt16 = 1
    static let FORWARD: UInt16 = 2
    static let BACKWARD: UInt16 = 3
    static let LEFT: UInt16 = 4
    static let RIGHT: UInt16 = 5
}
