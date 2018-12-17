//
//  ViewController.swift
//  TestApp
//
//  Created by Chris Sherwin on 14/12/2018.
//  Copyright © 2018 Chris Sherwin. All rights reserved.
//

import CoreMotion
import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    let motion = CMMotionManager()
    
    //MARK: Properties
    
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var rollValueLabel: UILabel!
    
    @IBOutlet weak var pitchValueLabel: UILabel!
    
    @IBOutlet weak var yawValueLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        nameTextField.delegate = self
    }

    //MARK: Actions
    
    @IBAction func goButton(_ sender: UIButton) {
        nameLabel.text = ""
        print("button pressed")
//        startAccelerometers()
    }

    @IBAction func startButton(_ sender: UIButton) {
        startDeviceMotionSensing()
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        stopDeviceMotionSensing()
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        nameLabel.text = nameTextField.text
    }
    
    func startDeviceMotionSensing() -> Void {
        if self.motion.isDeviceMotionAvailable && !self.motion.isDeviceMotionActive {
            self.motion.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {
                (deviceMotion, error) -> Void in
                if error == nil {
                    self.handleDeviceMotionUpdate(deviceMotion: deviceMotion)
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
    
    func handleDeviceMotionUpdate(deviceMotion: CMDeviceMotion?) {
        if let dm = deviceMotion {
            let attitude = dm.attitude

            let roll = degrees(radians: attitude.roll)
            let pitch = degrees(radians: attitude.pitch)
            let yaw = degrees(radians: attitude.yaw)

            self.rollValueLabel.text = String(roll)
            self.pitchValueLabel.text = String(pitch)
            self.yawValueLabel.text = String(yaw)
        }
    }
}

