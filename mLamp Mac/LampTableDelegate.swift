//
//  LampTableDelegate.swift
//  mLamp Mac
//
//  Created by Miroslav Zoricak on 19/08/15.
//  Copyright © 2015 Miroslav Zoricak. All rights reserved.
//

import Foundation
import AppKit

class LampTableDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource, MLampManagerDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var colorCircleView: ColorCircleView!
    
    var lampManager = MLampManager()
    var lamps = [MLamp]()
    var selectedLamps = [MLamp]()
    
    override init() {
        super.init()
        
        lampManager.delegate = self
        lampManager.discover()
    }
    
    func mLampDidDiscoverLamp(mlamp: MLamp) {
        lamps = lampManager.lamps
        tableView?.reloadData()
    }
    
    func mLampDidUpdateNames() {
        lamps = lampManager.lamps
        tableView.reloadData()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return lamps.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return lamps[row].humanName
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        selectedLamps.removeAll()
        for lamp in PermutationGenerator(elements: lamps, indices: tableView.selectedRowIndexes) {
            selectedLamps.append(lamp)
        }
    }
    
    func tableView(tableView: NSTableView, setObjectValue object: AnyObject?, forTableColumn tableColumn: NSTableColumn?, row: Int) {
        let lamp = lamps[row]
        let name = object as! String
        
        lampManager.setName(name, forIdentifier: lamp.identifier)
    }
    
    @IBAction func changeLampColor(sender: AnyObject) {
        guard let color = colorCircleView.currentColor else {
            return
        }
        
        for var lamp in selectedLamps {
            lamp.color = color
        }
    }
}