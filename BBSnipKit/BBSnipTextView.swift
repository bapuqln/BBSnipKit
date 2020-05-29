//
//  BBSnipTextField.swift
//  BBSnipKit
//
//  Created by ACE_xW on 10/05/2020.
//  Copyright © 2020 ACE_xW. All rights reserved.
//

import Cocoa

class BBSnipTextView: NSTextView {
    var restrictBorder:NSRect = NSZeroRect
    var trackingArea:NSTrackingArea?
    private var lastDragLocation = NSZeroPoint
    
    override init(frame frameRect: NSRect, textContainer container: NSTextContainer?) {
        super.init(frame: frameRect, textContainer: container)
//        self.addTrackingArea(rect: frameRect)
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
//        self.addTrackingArea(rect: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
//        self.addTrackingArea(rect: self.bounds)

    }
    
//    func addTrackingArea(rect:NSRect) {
//        self.trackingArea = NSTrackingArea(rect: rect, options: [.mouseEnteredAndExited], owner: self, userInfo: nil)
//        self.addTrackingArea(self.trackingArea!)
//    }
//
//    override func updateTrackingAreas() {
//        super.updateTrackingAreas()
//        self.removeTrackingArea(self.trackingArea!)
//        self.addTrackingArea(rect: self.bounds)
//    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func keyDown(with event: NSEvent) {
        print("BBSnipTextView::keyDown")
        if event.keyCode == 53 {
            print("BBSnipTextView::keyDown | esc key down")
            BBSnipManager.shared().snipDrawType = .none
            self.superview?.window?.resignFirstResponder()
        }
        super.keyDown(with: event)
    }
    
    override func mouseEntered(with event: NSEvent) {
        print("BBSnipTextView::mouseEnter")
        BBSnipManager.shared().snipDrawType = .text
        (self.superview as! BBSnipView).toolbar.setButtonState(tag: .text, state: .on)
        self.window?.makeFirstResponder(self)
    }
    
    override func mouseExited(with event: NSEvent) {
        print("BBSnipTextView::mouseExit")
        BBSnipManager.shared().snipDrawType = .none
        (self.superview as! BBSnipView).toolbar.restoreButtonState()
        self.window?.resignFirstResponder()
    }
    
    override func mouseDown(with event: NSEvent) {
        BBSnipManager.shared().snipDrawType = .text
        self.superview?.window?.makeFirstResponder(self)
       self.lastDragLocation = self.superview!.convert(event.locationInWindow, from: nil)
    }
    
    override func mouseDragged(with event: NSEvent) {
        let dragLocation = self.superview!.convert(event.locationInWindow, from: nil)
        var origin = self.frame.origin
        origin.x = origin.x + (-self.lastDragLocation.x + dragLocation.x)
        origin.y = origin.y + (-self.lastDragLocation.y + dragLocation.y)
        if NSMaxX(self.frame) > NSMaxX(restrictBorder) - 2 {
            origin.x = NSMaxX(restrictBorder) - NSWidth(self.frame) - 2
        }
        if NSMaxY(self.frame) > NSMaxY(restrictBorder) - 2 {
            origin.y = NSMaxY(restrictBorder) - NSHeight(self.frame) - 2
        }
        if NSMinX(self.frame) < NSMinX(restrictBorder) - 2 {
            origin.x = NSMinX(restrictBorder) - 2
        }
        if NSMinY(self.frame) < NSMinY(restrictBorder) - 2 {
            origin.y = NSMinY(restrictBorder) - 2
        }
        self.setFrameOrigin(origin)
        self.lastDragLocation = dragLocation
    }
}
