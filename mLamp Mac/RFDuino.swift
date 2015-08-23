//
//  RFDuino.swift
//  mLamp Mac
//
//  Created by Miroslav Zoricak on 23/08/15.
//  Copyright © 2015 Miroslav Zoricak. All rights reserved.
//

import Foundation
import CoreBluetooth

public class RFDuino: NSObject, CBPeripheralDelegate {
    public var connected: Bool {
        get {
            return peripheral.state == CBPeripheralState.Connected
        }
    }
    
    private let serviceUuid = CBUUID(string: "2220")
    private let receiveUuid = CBUUID(string: "2221")
    private let sendUuid = CBUUID(string: "2222")
    private let disconectUuid = CBUUID(string: "2223")
    
    internal weak var manager: RFDuinoManager?
    internal var peripheral: CBPeripheral
    
    private var sendCharacteristic: CBCharacteristic?
    private var receiveCharacteristic: CBCharacteristic?
    private var disconnectCharacteristic: CBCharacteristic?
    
    private var dataQueue = Array<NSData>()
    
    init(manager: RFDuinoManager, peripheral: CBPeripheral) {
        self.manager = manager
        self.peripheral = peripheral
        
        super.init()
        
        self.peripheral.delegate = self
    }
    
    public func connect() {
        self.manager?.connectToRFDuino(self)
    }
    
    public func sendData(data: NSData) {
        dataQueue.append(data)
        flushData()
    }
    
    
    public func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service in peripheral.services! {
            peripheral.discoverCharacteristics([sendUuid, receiveUuid], forService: service)
        }
    }
    
    public func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
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
    
    internal func discoverServices() {
        self.peripheral.discoverServices([serviceUuid])
    }
    
    private func flushData() {
        if let characteristic = sendCharacteristic {
            for data in dataQueue {
                peripheral.writeValue(data, forCharacteristic: characteristic, type: CBCharacteristicWriteType.WithoutResponse)
            }
        }
    }
}

public func ==(lhs: RFDuino, rhs: RFDuino) -> Bool {
    return lhs.peripheral == rhs.peripheral
}