//
//  BBSnipView.swift
//  Main
//
//  Created by ACE_xW on 05/05/2020.
//  Copyright © 2020 ACE_xW. All rights reserved.
//

import Cocoa

class BBSnipView: NSView {
    var debugMode = false
    var windowsInfo:[[String:Any]]?
    var image:NSImage?
    var tipView:BBSnipLableView?
    var drawView:BBSnipDrawView!
    var currentDrawType:BBSnipDrawType = .rect
    var drawRect:NSRect = NSZeroRect
    var toolbar:BBSnipToolbar!
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.buildShowView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.buildShowView()
    }
    
    func showTip() -> Void {
        var mouseLocation = NSEvent.mouseLocation
        let frame = self.window?.frame ?? NSZeroRect
        if frame == NSZeroRect {
            return
        }
        if (mouseLocation.x > frame.origin.x + frame.size.width - 100) {
            mouseLocation.x -= 100;
        }
        if (mouseLocation.x < frame.origin.x) {
            mouseLocation.x = frame.origin.x;
        }
        if (mouseLocation.y > frame.origin.y + frame.size.height - 26) {
            mouseLocation.y -= 26;
        }
        if (mouseLocation.y < frame.origin.y) {
            mouseLocation.y = frame.origin.y;
        }
        let rect = NSMakeRect(mouseLocation.x, mouseLocation.y, 100, 25)
        let imageRect = NSIntersectionRect(self.drawRect, self.bounds)
        self.tipView?.text = "\(imageRect.size.width)×\(imageRect.size.height)"
        self.tipView?.frame = self.window!.convertFromScreen(rect)
        self.tipView?.isHidden = false
    }
        
    func addTrackingArea(rect:NSRect) -> Void {
        let trackingArea = NSTrackingArea(rect: rect, options: [.mouseMoved, .activeAlways], owner: self, userInfo: nil)
        self.addTrackingArea(trackingArea)
    }
    
    func prepareForDrawObject(drawType:BBSnipDrawType) -> Void {
        let imageRect = NSIntersectionRect(self.drawRect, self.bounds)
        self.drawView!.frame = imageRect
        self.drawView!.isHidden = false
        self.currentDrawType = drawType
        self.drawView!.currentDrawType = drawType
    }
    
    func onMouseDown(event:NSEvent) {
        self.drawView.onMouseDown(event: event)
    }
    
    func onMouseUp(event:NSEvent) {
        self.drawView.onMouseUp(event: event)
    }
    
    func onMouseMove(event:NSEvent) {
        self.drawView.onMouseMove(event: event)
    }
    
    func onMouseDrag(event:NSEvent) {
        self.drawView.onMouseDrag(event: event)
    }
    
    private func buildShowView() -> Void {
        self.wantsLayer = true
        self.toolbar = BBSnipToolbar(frame: NSZeroRect)
        self.addSubview(self.toolbar)
        self.drawView = BBSnipDrawView(frame: NSZeroRect)
        self.addSubview(self.drawView)
        let shadow = NSShadow()
        shadow.shadowBlurRadius = 5
        shadow.shadowColor = NSColor.black
        shadow.shadowOffset = CGSize(width: 1, height: 1)
        self.toolbar.shadow = shadow
    }
    
    func showToolbar() -> Void{
        let mouseLocation = NSEvent.mouseLocation
        var screenFrame = NSZeroRect
        for screen in NSScreen.screens {
            if NSPointInRect(mouseLocation, screen.frame) {
                screenFrame = screen.frame
                break
            }
        }
        
        let imageRect = NSIntersectionRect(self.drawRect, self.bounds)
        let toolbarSize = self.toolbar.estimateSize()
        var destFrame = NSMakeRect(imageRect.origin.x + imageRect.size.width - toolbarSize.width - 3, imageRect.origin.y - toolbarSize.height - 4, toolbarSize.width, toolbarSize.height)

        if NSMaxX(destFrame) > NSMaxX(screenFrame) {
            destFrame.origin.x = screenFrame.width - destFrame.size.width - 3
        }
        if NSMinX(destFrame) < NSMinX(screenFrame) {
            destFrame.origin.x = screenFrame.origin.x + 3
        }
        if NSMinY(destFrame) < NSMinY(screenFrame) {
            destFrame.origin.y = imageRect.origin.y + imageRect.height + 3
        }
        if NSMaxY(destFrame) > NSMaxY(screenFrame) {
            destFrame.origin.y = imageRect.size.height - destFrame.height - 3
        }

        self.toolbar.frame = destFrame
        self.toolbar.layoutIcons()
        self.toolbar.isHidden = false
    }
    
    func hideToolbar() -> Void {
        self.toolbar.isHidden = true
    }
    
    private func drawDebugInfo() {
        guard self.windowsInfo != nil else {
            return
        }
        for windowInfo in self.windowsInfo! {
            let windowTitle = windowInfo[kCGWindowName as String] as? String
            let windowName = windowInfo[kCGWindowOwnerName as String] as! String
            let sizeInfo = windowInfo[kCGWindowBounds as String] as! [String : Any]
            let windowHeight = sizeInfo["Height"] as! CGFloat
            let windowWidth = sizeInfo["Width"] as! CGFloat
            let windowOrigX = sizeInfo["X"] as! CGFloat
            let windowOrigY = sizeInfo["Y"] as! CGFloat
            let windowLayer = windowInfo[kCGWindowLayer as String] as! Int
            if windowLayer >= 0 {
                let finalRect = NSMakeRect(windowOrigX, NSScreen.main!.frame.size.height - windowOrigY - windowHeight, windowWidth, windowHeight)
                let showName = windowName + " " + (windowTitle ?? "")
                let drawText = NSMutableAttributedString(string: showName, attributes: [NSAttributedString.Key.font : NSFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor:NSColor.white, NSAttributedString.Key.backgroundColor:NSColor.red])
                drawText.draw(at: finalRect.origin)
                let sizeText = NSMutableAttributedString(string: "\(windowWidth)×\(windowHeight)", attributes: [NSAttributedString.Key.font : NSFont.systemFont(ofSize: 17), NSAttributedString.Key.foregroundColor:NSColor.white, NSAttributedString.Key.backgroundColor:NSColor.red]);
                sizeText.draw(at: NSMakePoint(finalRect.origin.x, finalRect.origin.y + finalRect.size.height))
                let path = NSBezierPath()
                path.appendRect(finalRect)
                NSColor.yellow.setStroke()
                path.stroke()
            }
        }
    }
    
    private func drawWindowBorder() {
        print("drawWindowBorder")
        let imageRect  = NSIntersectionRect(self.drawRect, self.bounds)
        self.image!.draw(in: imageRect, from: imageRect, operation: .sourceOver, fraction: 1.0)
        NSColor(calibratedRed: 17.0/255.0, green: 145.0/255.0, blue: 254.0/255.0, alpha: 1.0).set()
        let path = NSBezierPath()
        path.lineWidth = 4.0
        path.removeAllPoints()
        path.append(NSBezierPath(rect: imageRect))
        path.stroke()
        if BBSnipManager.shared().snipState == .adjustSelectedRect {
            NSColor.white.set()
            var count = 0
            while (count < 8) {
                let path = NSBezierPath()
                path.appendOval(in: BBSnipUtility.controllPoint(count, inRect: imageRect))
                path.fill()
                count = count + 1
            }
        }
        
        if debugMode {
            self.drawDebugInfo()
        }
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
            if self.image != nil {
                self.drawWindowBorder()
            }
    }
    
}
