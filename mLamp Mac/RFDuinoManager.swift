//
//  RFDuinoManager.swift
//  mLamp Mac
//
//  Created by Miroslav Zoricak on 19/08/15.
//  Copyright © 2015 Miroslav Zoricak. All rights reserved.
//

import Foundation
import CoreBluetooth

protocol RFDuinoManagerDelegate {
    func rfduinoManagerDidDiscoverPeripheral()
}

class RFDuino: NSObject, CBPeripheralDelegate {
    let serviceUuid = CBUUID(string: "2220")
    let receiveUuid = CBUUID(string: "2221")
    let sendUuid = CBUUID(string: "2222")
    let disconectUuid = CBUUID(string: "2223")
    
    var peripheral: CBPeripheral
    
    var sendCharacteristic: CBCharacteristic?
    var receiveCharacteristic: CBCharacteristic?
    var disconnectCharacteristic: CBCharacteristic?
    
    var dataQueue = Array<NSData>()
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        
        super.init()
    
        self.peripheral.delegate = self
    }
    
    func discoverServices() {
        self.peripheral.discoverServices([serviceUuid])
    }
    
    func sendData(data: NSData) {
        dataQueue.append(data)
        flushData()
    }
    
    func flushData() {
        if let characteristic = sendCharacteristic {
            for data in dataQueue {
                peripheral.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithoutResponse)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([sendUuid, receiveUuid], forService: service)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        for service in peripheral.services! {
            for characteristic in service.characteristics! {
                if characteristic.UUID == sendUuid {
                    sendCharacteristic = characteristic
                } else if characteristic.UUID == receiveUuid {
                    receiveCharacteristic = characteristic
                } else if characteristic.UUID == disconectUuid {
                    disconnectCharacteristic = characteristic
                }
            }
        }
        
        flushData()
    }
}

func ==(lhs: RFDuino, rhs: RFDuino) -> Bool {
    return lhs.peripheral == rhs.peripheral
}

class RFDuinoManager: NSObject, CBCentralManagerDelegate {
    let serviceUUID = CBUUID(string: "2220")
    var centralManager = CBCentralManager()
    var rfduinos = Array<RFDuino>()
    var delegate : RFDuinoManagerDelegate?
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() {
        let options = [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ]
        
        centralManager.scanForPeripheralsWithServices([serviceUUID], options: options)
    }
    
    func connectToRFDuino(rfduino: RFDuino) {
        centralManager.connectPeripheral(rfduino.peripheral, options: nil)
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        for rfduino in rfduinos {
            rfduino.discoverServices()
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        var containsRfduino = false
        for r in rfduinos {
            if r.peripheral.isEqual(peripheral) {
                containsRfduino = true
            }
        }
        
        if !containsRfduino {
            let rfduino = RFDuino(peripheral: peripheral)
            
            rfduinos.append(rfduino)
            
            delegate?.rfduinoManagerDidDiscoverPeripheral()
        }
    }
    
    func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
    }
}