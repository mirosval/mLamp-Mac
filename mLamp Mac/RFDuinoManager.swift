//
//  RFDuinoManager.swift
//  mLamp Mac
//
//  Created by Miroslav Zoricak on 19/08/15.
//  Copyright © 2015 Miroslav Zoricak. All rights reserved.
//

import Foundation
import CoreBluetooth


public protocol RFDuinoManagerDelegate {
    func rfduinoManagerDidDiscoverPeripheral(rfduino: RFDuino)
}

public class RFDuinoManager: NSObject, CBCentralManagerDelegate {
    
    public var rfduinos = Array<RFDuino>()
    public var delegate : RFDuinoManagerDelegate?
    
    private let serviceUUID = CBUUID(string: "2220")
    private var centralManager = CBCentralManager()
    
    override init() {
        super.init()
        
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    public func startScan() {
        let options = [
            CBCentralManagerScanOptionAllowDuplicatesKey: false
        ]
        
        centralManager.scanForPeripheralsWithServices([serviceUUID], options: options)
    }
    
    public func startScanWithKnownIdentifiers(identifiers: [NSUUID]) {
        let peripherals = centralManager.retrievePeripheralsWithIdentifiers(identifiers)
        
        for peripheral in peripherals {
            NSLog("Found known mLamp: %@", peripheral.identifier.UUIDString)
            addPeripheralAsRfduino(peripheral)
        }
        
        startScan()
    }
    
    internal func connectToRFDuino(rfduino: RFDuino) {
        centralManager.connectPeripheral(rfduino.peripheral, options: nil)
    }
    
    internal func addPeripheralAsRfduino(peripheral: CBPeripheral) {
        var containsRfduino = false
        for r in rfduinos {
            if r.peripheral.isEqual(peripheral) {
                containsRfduino = true
            }
        }
        
        if !containsRfduino {
            let rfduino = RFDuino(manager: self, peripheral: peripheral)
            
            rfduinos.append(rfduino)
            
            delegate?.rfduinoManagerDidDiscoverPeripheral(rfduino)
        }
    }
    
    public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        for rfduino in rfduinos {
            rfduino.discoverServices()
        }
    }
    
    public func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
    }
    
    public func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        addPeripheralAsRfduino(peripheral)
    }
    
    public func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        
    }
    
    public func centralManagerDidUpdateState(central: CBCentralManager) {
        
    }
}