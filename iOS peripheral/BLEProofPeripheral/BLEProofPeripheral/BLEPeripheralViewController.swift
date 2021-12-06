//
//  ViewController.swift
//  BLEProofPeripheral
//
//  Created by Alexander Lavrushko on 22/03/2021.
//

import UIKit
import CoreBluetooth
import CoreMotion

class BLEPeripheralViewController: UIViewController {

   
    
  
//
//    // A
    let uuidService = CBUUID(string: "72f99129-592c-4ed2-b6e2-8754c03c2f0f")
    let uuidCharForIndicate = CBUUID(string: "72f99130-592c-4ed2-b6e2-8754c03c2f0f")
    let uuidCharForIndicateY = CBUUID(string: "72f99131-592c-4ed2-b6e2-8754c03c2f0f")
    let uuidCharForIndicateZ = CBUUID(string: "72f99132-592c-4ed2-b6e2-8754c03c2f0f")
    let uuidCharForWrite = CBUUID(string: "72f99133-592c-4ed2-b6e2-8754c03c2f0f")
    let uuidCharForRead = CBUUID(string: "72f99134-592c-4ed2-b6e2-8754c03c2f0f")


    
    //B
//    let uuidService = CBUUID(string: "a9edf38d-296c-4bd7-9289-eb70656c4fe2")
//    let uuidCharForIndicate = CBUUID(string: "a9edf38e-296c-4bd7-9289-eb70656c4fe2")
//    let uuidCharForIndicateY = CBUUID(string: "a9edf39b-296c-4bd7-9289-eb70656c4fe2")
//    let uuidCharForIndicateZ = CBUUID(string: "a9edf39c-296c-4bd7-9289-eb70656c4fe2")
//    let uuidCharForWrite = CBUUID(string: "a9edf38f-296c-4bd7-9289-eb70656c4fe2")
//    let uuidCharForRead = CBUUID(string: "a9edf38e-296c-4bd7-9289-eb70656c4fe2")




    var blePeripheral: CBPeripheralManager!
    var charForIndicate: CBMutableCharacteristic?
    var charForIndicateY: CBMutableCharacteristic?
    var charForIndicateZ: CBMutableCharacteristic?
    var subscribedCentrals = [CBCentral]()
    var motion: CMMotionManager!
    var accData: Data!
    var timer: Timer!
    var t: String!

    // UI related properties
    @IBOutlet weak var textViewStatus: UITextView!
    @IBOutlet weak var textViewLog: UITextView!
    @IBOutlet weak var textFieldAdvertisingData: UITextField!
    @IBOutlet weak var textFieldDataForRead: UITextField!
    @IBOutlet weak var textFieldDataForWrite: UITextField!
    @IBOutlet weak var textFieldDataForIndicate: UITextField!
    @IBOutlet weak var labelSubscribersCount: UILabel!
    @IBOutlet weak var switchAdvertising: UISwitch!

    let timeFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        textViewStatus.layer.borderWidth = 1
        textViewStatus.layer.borderColor = UIColor.gray.cgColor
        //textViewLog.layer.borderWidth = 1
        //textViewLog.layer.borderColor = UIColor.gray.cgColor

        textFieldDataForWrite.isUserInteractionEnabled = false

        // text field delegate will hide keyboard after "return" is pressed
        textFieldAdvertisingData.delegate = self
        textFieldDataForRead.delegate = self
        textFieldDataForWrite.delegate = self
        textFieldDataForIndicate.delegate = self

        timeFormatter.dateFormat = "HH:mm:ss"
//        textViewLog.layoutManager.allowsNonContiguousLayout = false // fixes not working scrollRangeToVisible
        //appendLog("app start")

        initBLE()
        
        motion = CMMotionManager()
        startAccelerometers()
    }

    @IBAction func onSwitchChangeAdvertising(_ sender: UISwitch) {
        if sender.isOn {
            bleStartAdvertising("1233")
        } else {
            bleStopAdvertising()
        }
    }

    @IBAction func onTapSendIndication(_ sender: Any) {
        bleSendIndication(textFieldDataForIndicate.text ?? "")
    }

    @IBAction func onTapOpenSettings(_ sender: Any) {
        let settingsUrl = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(settingsUrl, options: [:], completionHandler: nil)
    }

    @IBAction func onTapClearLog(_ sender: Any) {
        //textViewLog.text = "Logs:"
        //appendLog("log cleared")
    }
}

// MARK: - UI related methods
extension BLEPeripheralViewController {
//    func appendLog(_ message: String) {
//        let logLine = "\(timeFormatter.string(from: Date())) \(message)"
//        print("DEBUG: \(logLine)")
//        //textViewLog.text += "\n\(logLine)"
//        //let lastSymbol = NSRange(location: textViewLog.text.count - 1, length: 1)
//        //textViewLog.scrollRangeToVisible(lastSymbol)
//
//        updateUIStatus()
//    }

    func updateUIStatus() {
        textViewStatus.text = bleGetStatusString()
    }

    func updateUIAdvertising() {
        let isAdvertising = blePeripheral?.isAdvertising ?? false
        switchAdvertising.isOn = isAdvertising
    }

    func updateUISubscribers() {
        labelSubscribersCount.text = "\(subscribedCentrals.count)"
    }
}

extension BLEPeripheralViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - BLE related methods
extension BLEPeripheralViewController {

    private func initBLE() {
        // using DispatchQueue.main means we can update UI directly from delegate methods
        blePeripheral = CBPeripheralManager(delegate: self, queue: DispatchQueue.main)

        // BLE service must be created AFTER CBPeripheralManager receives .poweredOn state
        // see peripheralManagerDidUpdateState
    }

    private func buildBLEService() -> CBMutableService {

        // create characteristics
        let charForRead = CBMutableCharacteristic(type: uuidCharForRead,
                                                  properties: .read,
                                                  value: nil,
                                                  permissions: .readable)
        let charForWrite = CBMutableCharacteristic(type: uuidCharForWrite,
                                                   properties: .write,
                                                   value: nil,
                                                   permissions: .writeable)
        let charForIndicate = CBMutableCharacteristic(type: uuidCharForIndicate,
                                                      properties: [.notify, .write, .read],
                                                      value: nil,
                                                      permissions: [.readable, .writeable])
        let charForIndicateY = CBMutableCharacteristic(type: uuidCharForIndicateY,
                                                      properties: [.notify, .write, .read],
                                                      value: nil,
                                                      permissions: [.readable, .writeable])
        let charForIndicateZ = CBMutableCharacteristic(type: uuidCharForIndicateZ,
                                                      properties: [.notify, .write, .read],
                                                      value: nil,
                                                      permissions: [.readable, .writeable])
        self.charForIndicate = charForIndicate
        self.charForIndicateY = charForIndicateY
        self.charForIndicateZ = charForIndicateZ

        // create service
        let service = CBMutableService(type: uuidService, primary: true)
        service.characteristics = [charForIndicate]
        return service
    }

    private func bleStartAdvertising(_ advertisementData: String) {
        let dictionary: [String: Any] = [CBAdvertisementDataServiceUUIDsKey: [uuidService],
                                         CBAdvertisementDataLocalNameKey: advertisementData]
        //appendLog("startAdvertising")
        blePeripheral.startAdvertising(dictionary)
    }

    private func bleStopAdvertising() {
        //appendLog("stopAdvertising")
        blePeripheral.stopAdvertising()
    }

    private func bleSendIndication(_ valueString: String) {
        guard let charForIndicate = charForIndicate else {
           // appendLog("cannot indicate, characteristic is nil")
            return
        }
        let data = valueString.data(using: .utf8) ?? Data()
        let result = blePeripheral.updateValue(data, for: charForIndicate, onSubscribedCentrals: nil)
        let resultStr = result ? "true" : "false"
        //appendLog("updateValue result = '\(resultStr)' value = '\(valueString)'")
    }


   
    private func bleGetStatusString() -> String {
        guard let blePeripheral = blePeripheral else { return "not initialized" }
        switch blePeripheral.state {
        case .unauthorized:
            return blePeripheral.state.stringValue + " (allow in Settings)"
        case .poweredOff:
            return "Bluetooth OFF"
        case .poweredOn:
            let advertising = blePeripheral.isAdvertising ? "advertising" : "not advertising"
            return "ON, \(advertising)"
        default:
            return blePeripheral.state.stringValue
        }
    }
}

// MARK: - CBPeripheralManagerDelegate
extension BLEPeripheralViewController: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
       // appendLog("didUpdateState: \(peripheral.state.stringValue)")

        if peripheral.state == .poweredOn {
            //appendLog("adding BLE service")
            blePeripheral.add(buildBLEService())
        }
    }

    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
           // appendLog("didStartAdvertising: error: \(error.localizedDescription)")
        } else {
            //appendLog("didStartAdvertising: success")
        }
        updateUIAdvertising()
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if let error = error {
            //appendLog("didAddService: error: \(error.localizedDescription)")
        } else {
            //appendLog("didAddService: success: \(service.uuid.uuidString)")
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager,
                           central: CBCentral,
                           didSubscribeTo characteristic: CBCharacteristic) {
        //appendLog("didSubscribeTo UUID: \(characteristic.uuid.uuidString)")
        if characteristic.uuid == uuidCharForIndicate {
            subscribedCentrals.append(central)
            updateUISubscribers()
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager,
                           central: CBCentral,
                           didUnsubscribeFrom characteristic: CBCharacteristic) {
        //appendLog("didUnsubscribeFrom UUID: \(characteristic.uuid.uuidString)")
        if characteristic.uuid == uuidCharForIndicate {
            subscribedCentrals.removeAll { $0.identifier == central.identifier }
            updateUISubscribers()
        }
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        var log = "didReceiveRead UUID: \(request.characteristic.uuid.uuidString)"
        log += "\noffset: \(request.offset)"

        switch request.characteristic.uuid {
        case uuidCharForIndicate:
//            appendLog(
//                String(decoding: accData ?? Data(), as: UTF8.self)
//                )
            let textValue =  self.t
            //log += "\nresponding with success, value = '\(textValue)'"
            request.value = textValue!.data(using: .utf8)
            blePeripheral.respond(to: request, withResult: .success)
            //bleSendIndication("apple2")
           // bleSendIndicationY("mango")
           // bleSendIndicationZ("orange")
        default:
                log += "\nresponding with attributeNotFound"
            blePeripheral.respond(to: request, withResult: .attributeNotFound)
        }
        //appendLog(log)
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        var log = "didReceiveWrite requests.count = \(requests.count)"
        requests.forEach { (request) in
            log += "\nrequest.offset: \(request.offset)"
            log += "\nrequest.char.UUID: \(request.characteristic.uuid.uuidString)"
            switch request.characteristic.uuid {
            case uuidCharForWrite:
                let data = request.value ?? Data()
                let textValue = String(data: data, encoding: .utf8) ?? ""
                textFieldDataForWrite.text = textValue
                log += "\nresponding with success, value = '\(textValue)'"
                //blePeripheral.respond(to: request, withResult: .success)
            default:
                log += "\nresponding with attributeNotFound"
               // blePeripheral.respond(to: request, withResult: .attributeNotFound)
            }
        }
        //appendLog(log)
    }

    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        //appendLog("isReadyToUpdateSubscribers")
    }
   
    func startAccelerometers() {
       // Make sure the accelerometer hardware is available.
       if self.motion.isAccelerometerAvailable {
          self.motion.accelerometerUpdateInterval = 1.0 / 200.0  // 60 Hz
          self.motion.startAccelerometerUpdates()

          // Configure a timer to fetch the data.
          self.timer = Timer(fire: Date(), interval: (1.0/200.0),
                repeats: true, block: { (timer) in
             // Get the accelerometer data.
             if let data = self.motion.accelerometerData {
                let x = data.acceleration.x
                let y = data.acceleration.y
                let z = data.acceleration.z
                self.t = String(format: "%.2f", x) + " " + String(format: "%.2f", y) + " " +  String(format: "%.2f", z)
               // self.appendLog(self.t)
                 
                // Use the accelerometer data in your app.
             }
          })

          // Add the timer to the current run loop.
           RunLoop.current.add(self.timer, forMode: RunLoop.Mode.default)
       }
    }
}

// MARK: - Other extensions
extension CBManagerState {
    var stringValue: String {
        switch self {
        case .unknown: return "unknown"
        case .resetting: return "resetting"
        case .unsupported: return "unsupported"
        case .unauthorized: return "unauthorized"
        case .poweredOff: return "poweredOff"
        case .poweredOn: return "poweredOn"
        @unknown default: return "\(rawValue)"
        }
    }
}


