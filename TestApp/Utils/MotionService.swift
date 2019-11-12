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
    var attitude: AttitudeDegrees = AttitudeDegrees(roll: 0, pitch: 0, yaw: 0)
    
    func startDeviceMotionSensing(attitudeHandler: @escaping (AttitudeChange) -> Void) -> Void {
        print("startDeviceMotionSensing [self.motion.isDeviceMotionAvailable: \(self.motion.isDeviceMotionAvailable)]")
        print("isDeviceMotionActive [\(self.motion.isDeviceMotionActive)]")
        
        if self.motion.isDeviceMotionAvailable && !self.motion.isDeviceMotionActive {
            self.motion.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {
                (deviceMotion, error) -> Void in
                if error == nil {
                    if let newAtt = self.getAttitudeDegrees(deviceMotion: deviceMotion) {
                        if newAtt != self.attitude {
                            attitudeHandler(
                                AttitudeChange(new: newAtt, old: self.attitude)
                            )
                            self.attitude = newAtt
                        }
                    }
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
    
    func getAttitudeDegrees(deviceMotion: CMDeviceMotion?) -> AttitudeDegrees? {
        if let dm = deviceMotion {
            let newAttDegrees = AttitudeDegrees(
                roll: degrees(radians: dm.attitude.roll),
                pitch: degrees(radians: dm.attitude.pitch),
                yaw: degrees(radians: dm.attitude.yaw)
            )
            return newAttDegrees
        } else {
            return nil
        }
    }
}
