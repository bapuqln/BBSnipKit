//
//  BBSnipToolbarButton.swift
//  BBSnipKit
//
//  Created by ACE_xW on 05/05/2020.
//  Copyright © 2020 ACE_xW. All rights reserved.
//

import Cocoa

class BBSnipToolbarButton: NSButton {
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.buildShowView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.buildShowView()
    }
    
    private func buildShowView() {
        self.wantsLayer = true
        self.bezelStyle = .regularSquare
        self.setButtonType(.toggle)
        self.isBordered = false
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
