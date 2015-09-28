//
//  LampViewController.swift
//  mLamp Mac
//
//  Created by Miroslav Zoricak on 28/09/15.
//  Copyright © 2015 Miroslav Zoricak. All rights reserved.
//

import Foundation
import AppKit

class LampViewController: NSViewController {
    
    @IBOutlet weak var outlineView: NSOutlineView!
    
    override func viewDidAppear() {
        outlineView.expandItem(nil, expandChildren: true)
    }
}