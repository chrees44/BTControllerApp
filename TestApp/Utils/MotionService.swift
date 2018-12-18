//
//  MotionService.swift
//  BT-Controller-App
//
//  Created by Chris Sherwin on 18/12/2018.
//  Copyright © 2018 Chris Sherwin. All rights reserved.
//

import Foundation
import CoreMotion

class MotionService {

    let motion = CMMotionManager()

    func startDeviceMotionSensing(attitudeHandler: @escaping (AttitudeDegrees?) -> Void) -> Void {
        if self.motion.isDeviceMotionAvailable && !self.motion.isDeviceMotionActive {
            self.motion.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {
                (deviceMotion, error) -> Void in
                if error == nil {
                    attitudeHandler(
                        self.handleDeviceMotionUpdate(deviceMotion: deviceMotion))
                } else {
                    print(String(describing: error))
                }
            })
        }
    }
    
    func stopDeviceMotionSensing() -> Void {
        if self.motion.isDeviceMotionActive {
            self.motion.stopDeviceMotionUpdates()
        }
    }
    
    func degrees(radians: Double) -> Int {
        return Int(180 / .pi * radians)
    }
    
    func handleDeviceMotionUpdate(deviceMotion: CMDeviceMotion?) -> AttitudeDegrees? {
        if let dm = deviceMotion {
            let attitude = dm.attitude
            
            let roll = degrees(radians: attitude.roll)
            let pitch = degrees(radians: attitude.pitch)
            let yaw = degrees(radians: attitude.yaw)
            
            return AttitudeDegrees(roll: roll, pitch: pitch, yaw: yaw)
        } else {
            return nil
        }
    }

}
