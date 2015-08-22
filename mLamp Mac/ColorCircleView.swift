//
//  ColorCircleView.swift
//  mLamp Mac
//
//  Created by Miroslav Zoricak on 22/08/15.
//  Copyright © 2015 Miroslav Zoricak. All rights reserved.
//

import Foundation
import AppKit

class ColorCircleView: NSControl {
    var currentColor: NSColor? = nil
    var currentPosition: NSPoint? = nil
    var currentSize: NSSize? = nil
    var colorWheelImage: NSImage? = nil
    
    override func drawRect(dirtyRect: NSRect) {
        currentSize = dirtyRect.size
        
        let size: NSSize
        
        // get the view rect in the device scaled coordinates
        // on retina this sould be equivalent to multiplying 
        // rect dimensions by 2.0, but this is cleaner
        if let backingRect = NSScreen.mainScreen()?.convertRectToBacking(dirtyRect) {
            size = backingRect.size
        } else {
            size = dirtyRect.size
        }
        
        // this either generates or retrieves the color wheel from cache
        guard let image = getCachedColorWheel(size) else {
            NSLog("Failed to obtain an image of the color wheel")
            return
        }
        
        // draw the color wheel
        image.drawInRect(dirtyRect)
        
        if let point = currentPosition {
            guard let ctx = NSGraphicsContext.currentContext()?.CGContext else {
                NSLog("Failed to get current graphics context")
                return
            }
            
            let side: CGFloat = 7.0
            
            NSColor.darkGrayColor().setStroke()
            
            // center of the wheel
            let center = NSMakePoint(dirtyRect.size.width / 2.0, dirtyRect.size.height / 2.0)
            
            // wheel radius
            let radius = min(dirtyRect.size.width, dirtyRect.size.height) / 2.0
            
            // point in the circle coordinate space with circle center at origin
            let localPoint = NSMakePoint(point.x - center.x, point.y - center.y)
            let angle = atan2(localPoint.x, localPoint.y)
            let distance = sqrt(pow(localPoint.x, 2.0) + pow(localPoint.y, 2.0))
            
            var clampedPoint = point
            
            if distance > radius {
                clampedPoint = NSMakePoint(
                    center.x + radius * sin(angle),
                    center.y + radius * cos(angle) - side
                )
            }
            
            let highlightRect = NSMakeRect(clampedPoint.x - side / 2.0, clampedPoint.y + side / 2.0, side, side)
            
            CGContextStrokeEllipseInRect(ctx, highlightRect)
            
            if let color = currentColor {
                color.setFill()
                NSColor.grayColor().setStroke()
                
                let ellipseRect = NSMakeRect(1.0, dirtyRect.height - 31.0, 30.0, 30.0)
                CGContextFillEllipseInRect(ctx, ellipseRect)
                CGContextStrokeEllipseInRect(ctx, ellipseRect)
            }
        }
    }
    
    func renderColorWheel(size: NSSize) -> NSImage? {
        // since we're gonna draw into a graphics context
        // we want to push the current one so that we can 
        // get back to it later
        NSGraphicsContext.saveGraphicsState()
        
        // create a context for the color wheel that we can draw into
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let ctx = CGBitmapContextCreate(
            nil,
            Int(size.width),
            Int(size.height),
            8,
            4 * Int(size.width),
            colorSpace,
            CGImageAlphaInfo.PremultipliedFirst.rawValue
            ) else {
            NSLog("Failed to create CGBitmapGraphicsContext")
            return nil
        }
        
        // make it active so we can draw into it
        let graphicsContext = NSGraphicsContext(CGContext: ctx, flipped: false)
        NSGraphicsContext.setCurrentContext(graphicsContext)
        
        // loop over the entire image
        for y in 0...Int(size.height) {
            for x in 0...Int(size.width) {
                let color = getColorForPoint(NSMakePoint(CGFloat(x), CGFloat(y)), size: size, allowOutside: false)
                
                color.setFill()
                
                // fill the pixel
                CGContextFillRect(ctx, NSMakeRect(CGFloat(x), CGFloat(y), 1.0, 1.0))
            }
        }
        
        let center = NSMakePoint(size.width / 2.0, size.height / 2.0)
        let radius = min(size.width, size.height) / 2.0
        
        NSColor.grayColor().setStroke()
        CGContextStrokeEllipseInRect(ctx, NSMakeRect(center.x - radius, center.y - radius, 2 * radius, 2 * radius))
        
        // get the image from the context
        guard let cgImage = CGBitmapContextCreateImage(ctx) else {
            NSLog("Failed to create bitmap CGImage from CGGraphicsContext")
            return nil
        }
        
        // dont forget to pop the graphics context
        NSGraphicsContext.restoreGraphicsState()
        
        // and make a NSImage
        return NSImage(CGImage: cgImage, size: size)
    }
    
    func getColorForPoint(point: NSPoint, size: NSSize, allowOutside: Bool) -> NSColor {
        // center of the wheel
        let center = NSMakePoint(size.width / 2.0, size.height / 2.0)
        
        // wheel radius
        let radius = min(size.width, size.height) / 2.0
        
        // point in the circle coordinate space with circle center at origin
        let localPoint = NSMakePoint(point.x - center.x, point.y - center.y)
        
        // angle between X axis and the current point
        let angle = atan2(localPoint.x, localPoint.y)
        // angle is -PI to +PI, we want it to be 0...1
        let normalizedAngle = (angle + CGFloat(M_PI)) / CGFloat(2.0 * M_PI)
        
        // distance from the circle center to the current pixel
        let distance = sqrt(pow(localPoint.x, 2.0) + pow(localPoint.y, 2.0))
        // express it as a fraction of the radius
        let normalizedDistance = distance / radius
        
        // inside the circle...
        let color: NSColor
        if  distance <= radius || allowOutside {
            color = NSColor(calibratedHue: normalizedAngle, saturation: normalizedDistance, brightness: 1.0, alpha: 1.0)
        } else { // outside
            color = NSColor(calibratedHue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 0.0)
        }
        
        return color
    }
    
    func getCachedColorWheel(size: NSSize) -> NSImage? {
        // do we have a cached version of this size?
        if let image = colorWheelImage {
            if image.size == size {
                return image // if so, return
            }
        }
        
        // if not, render
        colorWheelImage = renderColorWheel(size)
        
        return colorWheelImage
    }
    
    func updateValue(theEvent: NSEvent) {
        let position = self.convertPoint(theEvent.locationInWindow, fromView: nil)
        
        currentPosition = position
        currentColor = getColorForPoint(position, size: currentSize!, allowOutside: true)
        
        NSApp.sendAction(self.action, to: self.target, from: self)
        
        self.needsDisplay = true
    }
    
    override func mouseDown(theEvent: NSEvent) {
        updateValue(theEvent)
    }
    
    override func mouseDragged(theEvent: NSEvent) {
        updateValue(theEvent)
    }
}