//
//  MLampManager.swift
//  mLamp Mac
//
//  Created by Miroslav Zoricak on 23/08/15.
//  Copyright © 2015 Miroslav Zoricak. All rights reserved.
//

import Foundation

public protocol MLampManagerDelegate {
     func mLampDidDiscoverLamp(mlamp: MLamp)
}

public class MLampManager: RFDuinoManagerDelegate {
    public var delegate: MLampManagerDelegate?
    public private(set) var lamps = [MLamp]()
    
    private var rfduinoManager = RFDuinoManager()
    
    public func discover() {
        lamps.removeAll()
        rfduinoManager.delegate = self
        rfduinoManager.startScan()
    }
    
    public func getLampByIdentifier(identifier: NSUUID) -> MLamp? {
        for lamp in lamps {
            if lamp.identifier.isEqual(identifier) {
                return lamp
            }
        }
        
        return nil
    }
    
    public func getLampsByName(name: String) -> [MLamp] {
        return lamps.filter({ $0.humanName == name })
    }
    
    public func rfduinoManagerDidDiscoverPeripheral(rfduino: RFDuino) {
        var lamp = MLamp(rfduino: rfduino)
        
        lamp.humanName = ""
        
        lamps.append(lamp)
        delegate?.mLampDidDiscoverLamp(lamp)
    }
}