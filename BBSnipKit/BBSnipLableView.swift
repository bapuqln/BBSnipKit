//
//  BBSnipLableView.swift
//  BBSnipKit
//
//  Created by ACE_xW on 06/05/2020.
//  Copyright © 2020 ACE_xW. All rights reserved.
//

import Cocoa

class BBSnipLableView: NSView {
    var text:String?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let path = NSBezierPath(roundedRect: self.bounds, xRadius: 6, yRadius: 6)
        path.setClip()
        NSColor(calibratedWhite: 0.0, alpha: 0.8).setFill()
        path.fill()
        if text != nil {
            
        }
        // Drawing code here.
    }
    
}
