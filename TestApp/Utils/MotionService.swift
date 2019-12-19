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
    
    // How much an attitude needs to change to fire the handler
    let stepSizeInDegrees: Int = 10
    // How many steps to reach the 100% value
    let maxSteps: Int = 4
    // Calculated value to ensure the max is a multiple of the step size
    lazy var maxDegrees: Int = self.stepSizeInDegrees * self.maxSteps
    
    let motion = CMMotionManager()
    var attitude: AttitudeDegrees = AttitudeDegrees(roll: 0, pitch: 0, yaw: 0)
    
    func startDeviceMotionSensing(attitudeHandler: @escaping (AttitudeChange) -> Void) -> Void {
        print("startDeviceMotionSensing [self.motion.isDeviceMotionAvailable: \(self.motion.isDeviceMotionAvailable)]")
        
        if self.motion.isDeviceMotionAvailable && !self.motion.isDeviceMotionActive {
            self.motion.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {
                (deviceMotion, error) -> Void in
                if error == nil {
                    if let newAtt = self.getAttitudeDegrees(deviceMotion: deviceMotion) {
                        
                        let newAttitude = self.changeDetctor(
                            newAtt: newAtt,
                            oldAtt: self.attitude,
                            step: self.stepSizeInDegrees,
                            maxDegrees: self.maxDegrees)
                        
                        if let att = newAttitude {
                            attitudeHandler(
                                AttitudeChange(new: att, old: self.attitude)
                            )
                            self.attitude = att
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
    
    
    // Determines whether roll or pitch have changed.
    private func changeDetctor(newAtt: AttitudeDegrees,
                               oldAtt: AttitudeDegrees,
                               step: Int,
                               maxDegrees: Int) -> AttitudeDegrees? {
        // If we want to include yaw changes then can use ??
        
        let newRoll: Int = comparer(newVal: newAtt.roll, oldVal: oldAtt.roll, step: step, maxDegrees: maxDegrees)
        let newPitch: Int = comparer(newVal: newAtt.pitch, oldVal: oldAtt.pitch, step: step, maxDegrees: maxDegrees)
        
        if newRoll != oldAtt.roll || newPitch != oldAtt.pitch {
            //            print("changeDetctor [old.Roll: \(oldAtt.roll), new.Roll: \(newAtt.roll), new: \(newRoll), \(newPitch)]")
            return AttitudeDegrees(roll: newRoll, pitch: newPitch, yaw: 0)
        } else {
            return nil
        }
    }
    
    // Works out whether a value has increased to the next step.
    // Returns the new step value or the original value.
    private func comparer(newVal: Int, oldVal: Int, step: Int, maxDegrees: Int) -> Int {
        let polarity: Int = newVal > 0 ? 1 : -1
        
        if abs(newVal) < step && abs(oldVal) >= step {
            return 0
        } else if abs(newVal) >= maxDegrees {
            if abs(oldVal) < maxDegrees {
                return maxDegrees * polarity
            } else {
                return oldVal
            }
        } else if abs(newVal) >= abs(oldVal) + step {
            return oldVal + step * polarity
        } else if abs(newVal) <= abs(oldVal) - step {
            return oldVal - step * polarity
        } else {
            return oldVal
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
