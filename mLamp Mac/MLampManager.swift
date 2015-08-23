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
    private var knownIdentifiers = [NSUUID: String]()
    
    public init() {
        loadKnownIdentifiers()
    }
    
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
    
    private func loadKnownIdentifiers() {
        knownIdentifiers.removeAll()
        
        guard let url = getKnownIdentifierStorageURL() else {
            return
        }
        
        guard let dict = NSDictionary(contentsOfURL: url) else {
            NSLog("Failed to load known identifiers")
            return
        }
        
        for identifier in dict {
            knownIdentifiers[identifier.key as! NSUUID] = (identifier.value as! String)
        }
    }
    
    private func saveKnownIdentifiers() {
        guard let url = getKnownIdentifierStorageURL() else {
            return
        }
        
        let dict = NSMutableDictionary()
        for identifier in knownIdentifiers {
            dict.setValue(identifier.0.UUIDString, forKey: identifier.1)
        }
        
        dict.writeToURL(url, atomically: true)
    }
    
    private func getKnownIdentifierStorageURL() -> NSURL? {
        let directory: NSURL
        do {
            directory = try NSFileManager.defaultManager().URLForDirectory(
                NSSearchPathDirectory.ApplicationSupportDirectory,
                inDomain: NSSearchPathDomainMask.UserDomainMask,
                appropriateForURL: nil,
                create: true)
        } catch {
            NSLog("Failed to find Application Support Directory")
            return nil
        }
        
        let path = directory.URLByAppendingPathComponent("known_lamps.plist")
        NSLog("Known lamp path has been set to: %@", path)
        
        return path
    }
}