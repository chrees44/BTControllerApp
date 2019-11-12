//
//  AttitudeDegrees.swift
//  BT-Controller-App
//
//  Created by Chris Sherwin on 18/12/2018.
//  Copyright © 2018 Chris Sherwin. All rights reserved.
//

struct AttitudeDegrees: Equatable {
    let roll: Int
    let pitch: Int
    let yaw: Int
    
    /** Whether the phone is level (within tolerance degrees) */
    func isLevel(tolerance: Int) -> Bool {
        self.roll < tolerance
            && self.roll > -tolerance
            && self.pitch < tolerance
            && self.pitch > -tolerance
    }
    
    static func == (lhs: AttitudeDegrees, rhs: AttitudeDegrees) -> Bool {
        return lhs.roll == rhs.roll
            && lhs.pitch == rhs.pitch
            && lhs.yaw == rhs.yaw
    }
    
    static func != (lhs: AttitudeDegrees, rhs: AttitudeDegrees) -> Bool {
        return !(lhs == rhs)
    }
}
