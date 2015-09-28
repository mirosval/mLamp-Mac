//
//  LampTableDelegate.swift
//  mLamp Mac
//
//  Created by Miroslav Zoricak on 19/08/15.
//  Copyright © 2015 Miroslav Zoricak. All rights reserved.
//

import Foundation
import AppKit

class LampCellView: NSTableCellView {
    var lamp: MLamp?
}

class LampTableDelegate: NSObject, NSOutlineViewDelegate, NSOutlineViewDataSource, NSTextFieldDelegate, MLampManagerDelegate {
    
    @IBOutlet weak var outlineView: NSOutlineView!
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
        outlineView?.reloadData()
        
        outlineView?.expandItem(nil, expandChildren: true)
    }
    
    func mLampDidUpdateNames() {
        lamps = lampManager.lamps
        outlineView.reloadData()
        outlineView?.expandItem(nil, expandChildren: true)
    }
    
    func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
        if let _ = item {
            return lamps[index]
        } else {
            return lampManager
        }
    }
    
    func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
        return item is MLampManager
    }
    
    func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
        switch item {
        case _ as MLampManager:
            return lamps.count
        default:
            return 1
        }
    }
    
    func outlineView(outlineView: NSOutlineView, viewForTableColumn tableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
        switch item {
        case _ as MLampManager:
            let view = (outlineView.makeViewWithIdentifier("HeaderCell", owner: self) as! NSTableCellView)
            view.textField?.stringValue = "Found Lamps"
            return view
        case let lamp as MLamp:
            let view = (outlineView.makeViewWithIdentifier("DataCell", owner: self) as! LampCellView)
            view.textField?.stringValue = lamp.humanName
            view.textField?.delegate = self
            view.lamp = lamp
            return view
        default:
            return nil
        }
    }
    
    func outlineView(outlineView: NSOutlineView, isGroupItem item: AnyObject) -> Bool {
        return item is MLampManager
    }
    
    func outlineView(outlineView: NSOutlineView, shouldSelectItem item: AnyObject) -> Bool {
        return item is MLamp
    }
    
    func outlineViewSelectionDidChange(notification: NSNotification) {
        let indexSet = self.outlineView.selectedRowIndexes
        
        selectedLamps.removeAll()
        indexSet.enumerateIndexesUsingBlock({ (index, stop) -> Void in
            if let lamp = self.outlineView.itemAtRow(index) as? MLamp {
                self.selectedLamps.append(lamp)
            }
        })
    }
    
    override func controlTextDidEndEditing(obj: NSNotification) {
        if let field = obj.object as? NSTextField,
            lampCellView = field.superview as? LampCellView,
            lamp = lampCellView.lamp {
            lampManager.setName(field.stringValue, forIdentifier: lamp.identifier)
        }
    }
    
    @IBAction func changeLampColor(sender: AnyObject) {
        guard let color = colorCircleView.currentColor else {
            return
        }
        
        for lamp in selectedLamps {
            lamp.color = color
        }
    }
}