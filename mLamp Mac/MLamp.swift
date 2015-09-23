//
//  MLamp.swift
//  mLamp Mac
//
//  Created by Miroslav Zoricak on 23/08/15.
//  Copyright © 2015 Miroslav Zoricak. All rights reserved.
//

import Foundation
import AppKit

public enum MLampMode: UInt8 {
    case Reset = 0
    case Hold = 1
}

public struct MLamp {
    public var humanName: String = ""
    public var color: NSColor {
        didSet {
            guard let rfduino = backingRFDuino else {
                return
            }
            
            let r = UInt8(255 * color.redComponent)
            let g = UInt8(255 * color.greenComponent)
            let b = UInt8(255 * color.blueComponent)
            
            let data = NSData(bytes: [mode.rawValue, r, g, b] as [UInt8], length: 4)
            
            if !rfduino.connected {
                rfduino.connect()
            }
            
            rfduino.sendData(data)
//            NSLog("Sent %@ to lamp %@", data, humanName)
        }
    }
    
    public var mode: MLampMode = MLampMode.Reset
    
    internal var backingRFDuino: RFDuino? = nil
    internal var identifier: NSUUID = NSUUID()
    
    init(rfduino: RFDuino) {
        self.backingRFDuino = rfduino
        self.color = NSColor.blackColor()
        self.identifier = rfduino.peripheral.identifier
    }
}