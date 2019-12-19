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
    
    @IBOutlet weak var scanButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //MARK: Actions
    
    @IBAction func scanButton(_ sender: UIButton) {
        if scanButtonOutlet.titleLabel?.text == "Scan" {
            btSvc!.scanForPeripherals()
        } else {
            btSvc!.stopScanning()
        }
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
    
    func updateScanningState(isScanning: Bool) {
        //print("updateScanningState [\(isScanning))]")
        let title = isScanning ? "Scanning..." : "Scan"
        self.scanButtonOutlet.setTitle(title, for: .normal)
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
        
        if att.new.roll != att.old.roll {
            // Scale degrees to % of max and shift -100..100 to 0..200 so it can be sent as unsigned.
            let percent = 100 * att.new.roll / motionSvc.maxDegrees
            let shifted = percent + 100
            let unsigned = UInt16(truncatingIfNeeded: shifted)
            
            //print("handleDeviceMotionUpdate [roll: att.new.roll: \(att.new.roll), unsigned: \(unsigned)]")
            
            self.btSvc!.sendEvent(
                code: MicroBitEvents.MICROBIT_EVENT_SVC_FWD_BWD,
                value: unsigned
            )
        }
        
        if att.new.pitch != att.old.pitch {
            // Scale degrees to % of max and shift -100..100 to 0..200 so it can be sent as unsigned.
            let percent = 100 * att.new.pitch / motionSvc.maxDegrees
            let shifted = percent + 100
            let unsigned = UInt16(truncatingIfNeeded: shifted)
            
            //print("handleDeviceMotionUpdate [pitch: att.new.pitch: \(att.new.pitch), unsigned: \(unsigned)]")
            
            self.btSvc!.sendEvent(
                code: MicroBitEvents.MICROBIT_EVENT_SVC_LFT_RGT,
                value: unsigned
            )
        }
    }
}

