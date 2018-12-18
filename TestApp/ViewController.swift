//
//  ViewController.swift
//  TestApp
//
//  Created by Chris Sherwin on 14/12/2018.
//  Copyright © 2018 Chris Sherwin. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {

    let motionSvc = MotionService()
    let btSvc = BluetoothService()
    
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
        btSvc.scanForPeripherals()
//        nameLabel.text = "\(state)"
//        print("button pressed")
//        startAccelerometers()
    }

    @IBAction func startButton(_ sender: UIButton) {
        motionSvc.startDeviceMotionSensing(attitudeHandler: handleDeviceMotionUpdate)
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        motionSvc.stopDeviceMotionSensing()
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        nameLabel.text = nameTextField.text
    }
    
    func handleDeviceMotionUpdate(attitude: AttitudeDegrees?) {
        if let att = attitude {
            self.rollValueLabel.text = String(att.roll)
            self.pitchValueLabel.text = String(att.pitch)
            self.yawValueLabel.text = String(att.yaw)
        }
    }
}

