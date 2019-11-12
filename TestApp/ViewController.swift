//
//  ViewController.swift
//  TestApp
//
//  Created by Chris Sherwin on 14/12/2018.
//  Copyright © 2018 Chris Sherwin. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, UITextFieldDelegate, BluetoothServiceDelegate {
    
    let motionSvc = MotionService()
    var btSvc: BluetoothService?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        btSvc = BluetoothService(delegate: self)
    }
    
    //MARK: Properties
    
    //    @IBOutlet weak var nameTextField: UITextField!
    
    //    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var rollValueLabel: UILabel!
    
    @IBOutlet weak var pitchValueLabel: UILabel!
    
    @IBOutlet weak var yawValueLabel: UILabel!
    
    @IBOutlet weak var forwardLabel: UILabel!
    
    @IBOutlet weak var backLabel: UILabel!
    
    @IBOutlet weak var leftLabel: UILabel!
    
    @IBOutlet weak var rightLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK: Actions
    
    @IBAction func goButton(_ sender: UIButton) {
        btSvc!.scanForPeripherals()
    }
    
    @IBAction func startButton(_ sender: UIButton) {
        motionSvc.startDeviceMotionSensing(attitudeHandler: handleDeviceMotionUpdate)
    }
    
    @IBAction func stopButton(_ sender: UIButton) {
        motionSvc.stopDeviceMotionSensing()
    }
    
    @IBAction func connectRpiButton(_ sender: UIButton) {
        btSvc!.retrievePeripheral(uuid: btSvc!.uuidRpiBluezTest)
    }
    
    @IBAction func connectMicrobitButton(_ sender: UIButton) {
        btSvc!.retrievePeripheral(uuid: btSvc!.uuidMicrobit)
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //    func textFieldDidEndEditing(_ textField: UITextField) {
    //        nameLabel.text = nameTextField.text
    //    }
    
    // MARK: BluetoothServiceDelegate implementation
    
    func updateManagerState(state: String) {
        print("updateManagerState [\(state))]")
        self.statusLabel.text = state
    }
    
    func updatePeripheralState(uuid: UUID, state: CBPeripheralState) {
        let msg = btSvc!.getPeripheralState(state: state)
        print("updatePeripheralState [\(msg)]")
        self.statusLabel.text = msg
    }
    
    func updateReadValue(service: CBService, characteristic: CBCharacteristic, value: String) {
        print("updateReadValue [\(value)]")
    }
    
    
    func handleDeviceMotionUpdate(att: AttitudeChange) {
        self.rollValueLabel.text = String(att.new.roll)
        self.pitchValueLabel.text = String(att.new.pitch)
        self.yawValueLabel.text = String(att.new.yaw)
        
        if att.new.roll > 10 {
            if att.old.roll <= 10 {
                //            self.btSvc!.sendMatrixIcon(icon: MatrixIcons.ForwardArrow)
                self.btSvc!.sendEvent(
                    code: MicroBitEvents.MICROBIT_EVENT_SVC,
                    value: MicroBitEvents.FORWARD)
            }
            self.forwardLabel.isHidden = false
        } else {
            self.forwardLabel.isHidden = true
        }
        
        if att.new.roll < -10 {
            if  att.old.roll >= -10 {
                //            self.btSvc!.sendMatrixIcon(icon: MatrixIcons.BackwardArrow)
                self.btSvc!.sendEvent(
                    code: MicroBitEvents.MICROBIT_EVENT_SVC,
                    value: MicroBitEvents.BACKWARD)
            }
            self.backLabel.isHidden = false
        } else {
            self.backLabel.isHidden = true
        }
        
        if att.new.pitch < -10 {
            if  att.old.pitch >= -10 {
                self.btSvc!.sendEvent(
                    code: MicroBitEvents.MICROBIT_EVENT_SVC,
                    value: MicroBitEvents.LEFT)
            }
            self.leftLabel.isHidden = false
        } else {
            self.leftLabel.isHidden = true
        }
        
        if att.new.pitch > 10 {
            if att.old.pitch <= 10 {
                self.btSvc!.sendEvent(
                    code: MicroBitEvents.MICROBIT_EVENT_SVC,
                    value: MicroBitEvents.RIGHT)
            }
            self.rightLabel.isHidden = false
        } else {
            self.rightLabel.isHidden = true
        }
        
        // Check if we're level
        if att.new.isLevel(tolerance: 10) && !att.old.isLevel(tolerance: 10) {
            self.btSvc!.sendEvent(
                code: MicroBitEvents.MICROBIT_EVENT_SVC,
                value: MicroBitEvents.NEUTRAL )
        }
    }
}

