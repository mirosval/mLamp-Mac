//
//  LampTableDelegate.swift
//  mLamp Mac
//
//  Created by Miroslav Zoricak on 19/08/15.
//  Copyright © 2015 Miroslav Zoricak. All rights reserved.
//

import Foundation
import AppKit

class LampTableDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource, RFDuinoManagerDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var colorCircleView: ColorCircleView!
    
    var rfduinoManager = RFDuinoManager()
    var rfduinos = Array<RFDuino>()
    var selectedRFDuino: RFDuino?
    
    override init() {
        super.init()
        
        rfduinoManager.delegate = self
        
        rfduinoManager.startScan()
    }
    
    func rfduinoManagerDidDiscoverPeripheral() {
        rfduinos = rfduinoManager.rfduinos
        tableView.reloadData()
    }
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return rfduinos.count
    }
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {
        return rfduinos[row].peripheral.name
    }
    
    func tableViewSelectionDidChange(notification: NSNotification) {
        let rfduino = rfduinos[tableView.selectedRow]
        rfduinoManager.connectToRFDuino(rfduino)
        
        selectedRFDuino = rfduino
    }
    
    @IBAction func changeLampColor(sender: AnyObject) {
        guard let color = colorCircleView.currentColor else {
            return
        }
        
        let r = UInt8(255 * color.redComponent)
        let g = UInt8(255 * color.greenComponent)
        let b = UInt8(255 * color.blueComponent)
        
        let data = NSData(bytes: [0, r, g, b] as [UInt8], length: 4)
        selectedRFDuino?.sendData(data)
    }
}