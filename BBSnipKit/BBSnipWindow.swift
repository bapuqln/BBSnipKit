//
//  BBSnipWindow.swift
//  Main
//
//  Created by ACE_xW on 05/05/2020.
//  Copyright © 2020 ACE_xW. All rights reserved.
//

import Cocoa

public protocol BBSnipMouseDelegate:class{
    func onMouseDown(event:NSEvent) -> Void
    func onMouseUp(event:NSEvent) -> Void
    func onMouseDragged(event:NSEvent) -> Void
    func onMouseMoved(event:NSEvent) -> Void
}

class BBSnipWindow: NSWindow {
    weak var mouseDelegate:BBSnipMouseDelegate?
    override var isFloatingPanel: Bool {
        get{
            return true
        }
    }
    
    override var canBecomeMain: Bool {
        get {
            return true
        }
    }
    
    override func mouseMoved(with event: NSEvent) {
        self.mouseDelegate?.onMouseMoved(event: event)
    }
    
    override func mouseDown(with event: NSEvent) {
        self.mouseDelegate?.onMouseDown(event: event)
    }
    
    override func mouseUp(with event: NSEvent) {
        self.mouseDelegate?.onMouseUp(event: event)
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.mouseDelegate?.onMouseDragged(event: event)
    }
    
    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 {
            self.orderOut(nil)
            BBSnipManager.shared().endCapture(image: nil)
            return
        }
        super.keyDown(with: event)
    }
    
    override var canBecomeKey: Bool{
        get {
            return true
        }
    }

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
        self.acceptsMouseMovedEvents = true
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isMovableByWindowBackground = false
        self.alphaValue = 1.0
        self.isOpaque = false
        self.hasShadow = false
        self.hidesOnDeactivate = false
        self.isRestorable = false
        self.disableSnapshotRestoration()
        self.level = .screenSaver + 1
        self.isMovable = false
    }
}
