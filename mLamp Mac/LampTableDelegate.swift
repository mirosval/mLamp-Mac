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
    var selectedLamp: MLamp?
    
    override init() {
        super.init()
        
        lampManager.delegate = self
        lampManager.discover()
    }
    
    func mLampDidDiscoverLamp(mlamp: MLamp) {
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
        let lamp = lamps[tableView.selectedRow]
        selectedLamp = lamp
    }
    
    @IBAction func changeLampColor(sender: AnyObject) {
        guard let color = colorCircleView.currentColor else {
            return
        }
        
        selectedLamp?.color = color
    }
}