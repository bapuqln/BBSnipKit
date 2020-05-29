//
//  BBSnipUtility.swift
//  BBSnipKit
//
//  Created by ACE_xW on 05/05/2020.
//  Copyright © 2020 ACE_xW. All rights reserved.
//

import Foundation
import Cocoa
import CoreGraphics

class BBSnipUtility {
    /// ToDo: capture screen
    public class func caputreScreen(_ screen:NSScreen) -> CGImage? {
        return CGWindowListCreateImage(CGRect.infinite, .optionOnScreenOnly, kCGNullWindowID, CGWindowImageOption())
    }
    
    public class func poinDistance(fromPoint:NSPoint, toPoint:NSPoint) -> CGFloat {
        return (fromPoint.x - toPoint.x) * (fromPoint.x - toPoint.x) + (fromPoint.y - toPoint.y) * (fromPoint.y - toPoint.y)
    }
    
    public class func controllPoint(_ index:Int, inRect rect:NSRect) -> NSRect {
        var x = CGFloat(0)
        var y = CGFloat(0)
        switch (index) {
            case 0:
                x = NSMinX(rect);
                y = NSMaxY(rect);
                break;
            case 1:
                x = NSMidX(rect);
                y = NSMaxY(rect);
                break;
            case 2:
                x = NSMaxX(rect);
                y = NSMaxY(rect);
                break;
            case 3:
                x = NSMinX(rect);
                y = NSMidY(rect);
                break;
            case 4:
                x = NSMaxX(rect);
                y = NSMidY(rect);
                break;
            case 5:
                x = NSMinX(rect);
                y = NSMinY(rect);
                break;
            case 6:
                x = NSMidX(rect);
                y = NSMinY(rect);
                break;
            case 7:
                x = NSMaxX(rect);
                y = NSMinY(rect);
                break;

            default:
                break;
        }
        return NSMakeRect(x - 5, y - 5, 5 * 2, 5 * 2);
    }
    
    public class func uniformRect(rect:NSRect) -> NSRect {
        var x = rect.origin.x
        var y = rect.origin.y
        var w = rect.size.width
        var h = rect.size.height
        if w < 0 {
            x = x + w
            w = -w
        }
        if h < 0 {
            y = y + h
            h = -h
        }
        return NSMakeRect(x, y, w, h)
    }
    
    public class func rectToZero(rect:NSRect) -> NSRect {
        return NSOffsetRect(rect, -rect.origin.x, -rect.origin.y)
    }
    
    public class func dragPointCenter(index:Int, inRect:NSRect) -> NSPoint {
        var x:CGFloat = 0
        var y:CGFloat = 0
        switch (index) {
            case 0:
                x = NSMinX(inRect)
                y = NSMaxY(inRect)
                break
            case 1:
                x = NSMidX(inRect)
                y = NSMaxY(inRect)
                break
            case 2:
                x = NSMaxX(inRect)
                y = NSMaxY(inRect)
                break
            case 3:
                x = NSMinX(inRect)
                y = NSMidY(inRect)
                break
            case 4:
                x = NSMaxX(inRect)
                y = NSMidY(inRect)
                break
            case 5:
                x = NSMinX(inRect)
                y = NSMinY(inRect)
                break
            case 6:
                x = NSMidX(inRect)
                y = NSMinY(inRect)
                break
            case 7:
                x = NSMaxX(inRect)
                y = NSMinY(inRect)
                break

            default:
                break
        }
        return NSMakePoint(x, y)
    }
    
    public class func dragDirectionFromPoint(mousePoint:NSPoint, rect:NSRect) -> Int {
        let adjustLen:CGFloat = 8
        if NSWidth(rect) <= adjustLen * 2 || NSHeight(rect) <= adjustLen * 2  {
            if NSPointInRect(mousePoint, rect) {
                return 8
            }
        }
        let innerRect = NSInsetRect(rect, adjustLen, adjustLen)
        if NSPointInRect(mousePoint, innerRect) {
            return 8
        }
        let outRect = NSInsetRect(rect, -adjustLen, -adjustLen)
        if !NSPointInRect(mousePoint, outRect) {
            return -1
        }
        var minDistance = adjustLen * adjustLen
        var ret = -1
        var count = 0
        while count < 8 {
            let dragPoint = BBSnipUtility.dragPointCenter(index: count, inRect: rect)
            let distance = BBSnipUtility.poinDistance(fromPoint: dragPoint, toPoint: mousePoint)
            if distance < minDistance {
                minDistance = distance
                ret = count
            }
            count = count + 1
        }
        return ret
    }
    
    public class func imageByName(imageName:String) -> NSImage? {
        let path = "\(Bundle.main.bundlePath)/Contents/Frameworks/BBSnipKit.framework"
        let bundle = Bundle(path: path)
        return bundle?.image(forResource: imageName)
    }
    
    public class func windowRectToScreenRect(windowRect:CGRect) -> NSRect {
        var mainRect = NSScreen.main?.frame ?? NSZeroRect
        for screen in NSScreen.screens {
            if (screen.frame.origin.x == 0 && screen.frame.origin.y == 0) {
                mainRect = screen.frame;
                break
            }
        }
        let screenRect = NSMakeRect(windowRect.origin.x, mainRect.size.height - windowRect.size.height - windowRect.origin.y, windowRect.size.width, windowRect.size.height)
        return screenRect
    }
}

extension NSScreen {
    static func currentScreenScaleFactor() -> CGFloat {
        let mouseLocation = NSEvent.mouseLocation
        for screen in NSScreen.screens {
            if NSMouseInRect(mouseLocation, screen.frame, false) {
                return screen.backingScaleFactor
            }
        }
        return (NSScreen.main?.backingScaleFactor)!
    }
}
