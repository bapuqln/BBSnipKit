//
//  BBSnipToolbox.swift
//  BBSnipKit
//
//  Created by ACE_xW on 05/05/2020.
//  Copyright © 2020 ACE_xW. All rights reserved.
//

import Cocoa

enum BBSnipToolbarActionType:Int {
    case cancel
    case ok
    case rect
    case ellipse
    case arrow
    case pen
    case text
    case bar
}

class BBSnipToolbar: NSView {
    typealias ClickClosure = (_ tag:BBSnipToolbarActionType) -> Void
    var onClick:ClickClosure =  { tag in }
    
    let verticalPadding:CGFloat = 10
    let horizonPadding:CGFloat = 20
    let iconPadding:CGFloat =  20
    let iconWidth:CGFloat = 20
    
    var estimateWidth:CGFloat = 0
    var estimateHeight:CGFloat = 0
    
    private var rectButton:BBSnipToolbarButton?
    private var ellipseButton:BBSnipToolbarButton?
    private var arrowButton:BBSnipToolbarButton?
    private var textButton:BBSnipToolbarButton?
    private var penButton:BBSnipToolbarButton?
    private var cancelButton:BBSnipToolbarButton?
    private var verticalBar:BBSnipToolbarButton?
    private var okButton:BBSnipToolbarButton?
    private var buttons:[BBSnipToolbarButton] = []
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.buildShowView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.buildShowView()
    }
    
    private func generateToolbarButton(actionType:BBSnipToolbarActionType) -> BBSnipToolbarButton {
        if actionType == .bar {
            let button = BBSnipToolbarButton(frame: NSMakeRect(0, 0, 1, 12))
            button.wantsLayer = true
            button.layer?.backgroundColor = NSColor(calibratedRed: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0).cgColor
            return button
        } else {
            let button = BBSnipToolbarButton(frame: NSMakeRect(0, 0, 10, 10))
            button.tag = actionType.rawValue
            button.target = self
            button.imageScaling = .scaleAxesIndependently
            button.action = #selector(buttonClick(_:))
            button.wantsLayer = true
            button.layer?.borderColor = NSColor.red.cgColor
            return button
        }
    }
    
    private func buildShowView() {
        self.rectButton = self.generateToolbarButton(actionType: .rect)
        self.rectButton?.image = BBSnipUtility.imageByName(imageName: "ic_screenshot_mark")// NSImage(contentsOfFile: path + "ic_screenshot_mark.tiff")
        self.rectButton?.alternateImage = BBSnipUtility.imageByName(imageName: "ic_screenshot_mark_a")// NSImage(contentsOfFile: path + "ic_screenshot_mark_a.tiff")
        self.buttons.append(self.rectButton!)
        self.addSubview(self.rectButton!)
        
        self.ellipseButton = self.generateToolbarButton(actionType: .ellipse)
        self.buttons.append(self.ellipseButton!)
//        self.addSubview(self.ellipseButton!)
        
        self.arrowButton = self.generateToolbarButton(actionType: .arrow)
        self.buttons.append(self.arrowButton!)
//        self.addSubview(self.arrowButton!)
        
        self.textButton = self.generateToolbarButton(actionType: .text)
        self.textButton?.image = BBSnipUtility.imageByName(imageName: "ic_screenshot_text")// NSImage(contentsOfFile: path + "ic_screenshot_text.tiff")
        self.textButton?.alternateImage = BBSnipUtility.imageByName(imageName: "ic_screenshot_text_a") // NSImage(contentsOfFile: path + "ic_screenshot_text_a.tiff")
        self.buttons.append(self.textButton!)
        self.addSubview(self.textButton!)
        
        self.penButton = self.generateToolbarButton(actionType: .pen)
        self.buttons.append(self.penButton!)
//        self.addSubview(self.penButton!)
        
        self.verticalBar = self.generateToolbarButton(actionType: .bar)
        self.buttons.append(self.verticalBar!)
        self.addSubview(self.verticalBar!)
        
        self.cancelButton = self.generateToolbarButton(actionType: .cancel)
        self.cancelButton?.image = BBSnipUtility.imageByName(imageName: "ic_screenshot_close") //NSImage(contentsOfFile: path + "ic_screenshot_close.tiff")
        self.cancelButton?.alternateImage = BBSnipUtility.imageByName(imageName: "ic_screenshot_close_a") // NSImage(contentsOfFile: path + "ic_screenshot_close_a.tiff")
        self.buttons.append(self.cancelButton!)
        self.addSubview(self.cancelButton!)
        
        self.okButton = self.generateToolbarButton(actionType: .ok)
        self.okButton?.image = BBSnipUtility.imageByName(imageName: "ic_screenshot_done")//NSImage(contentsOfFile: path + "ic_screenshot_done.tiff")
        self.okButton?.alternateImage = BBSnipUtility.imageByName(imageName: "ic_screenshot_done_a")// NSImage(contentsOfFile: path + "ic_screenshot_done_a.tiff")
        self.buttons.append(self.okButton!)
        self.addSubview(self.okButton!)
    }
    
    func restoreButtonState() {
        for subView in self.subviews {
            if subView is BBSnipToolbarButton {
                let button = subView as! BBSnipToolbarButton
                button.state = .off
            }
        }
    }
    
    func setButtonState(tag:BBSnipToolbarActionType, state:NSControl.StateValue) {
        for subView in self.subviews {
            if subView is BBSnipToolbarButton {
                let button = (subView as! BBSnipToolbarButton)
                if button.tag == tag.rawValue {
                    button.state = state
                }
            }
        }
    }
    
    func setButtonState(execeptTag:BBSnipToolbarActionType, state:NSControl.StateValue) {
        for subView in self.subviews {
            if subView is BBSnipToolbarButton {
                let button = (subView as! BBSnipToolbarButton)
                if button.tag != execeptTag.rawValue {
                    button.state = state
                }
            }
        }
    }
    
    @objc func buttonClick(_ sender:BBSnipToolbarButton) {
        self.setButtonState(execeptTag: BBSnipToolbarActionType(rawValue: sender.tag)!, state: .off)
        self.onClick(BBSnipToolbarActionType(rawValue: sender.tag)!)
    }
    
    override func mouseDown(with event: NSEvent) {
        
    }
    
    func layoutIcons() -> Void {
        self.rectButton?.frame = NSMakeRect(iconWidth, verticalPadding, iconWidth, iconWidth)
        self.textButton?.frame = NSMakeRect(self.rectButton!.frame.origin.x + 2 * iconWidth, verticalPadding, iconWidth, iconWidth)
        self.verticalBar?.frame = NSMakeRect(self.textButton!.frame.origin.x + 2 * iconWidth, verticalPadding, 2, iconWidth)
        self.cancelButton?.frame = NSMakeRect(self.verticalBar!.frame.origin.x + 2 + iconWidth, verticalPadding, iconWidth, iconWidth)
        self.okButton?.frame = NSMakeRect(self.cancelButton!.frame.origin.x + 2 * iconWidth, verticalPadding, iconWidth, iconWidth)
    }
    
    func estimateSize() -> NSSize {
        let iconsWidth:CGFloat = CGFloat(self.subviews.count) * iconWidth
        let paddingWidth:CGFloat = CGFloat(self.subviews.count) * iconPadding
        estimateWidth = iconsWidth + CGFloat(2) + paddingWidth
        estimateHeight = CGFloat(2) * verticalPadding + iconWidth
        return NSMakeSize(estimateWidth, estimateHeight)
    }
        
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        NSColor(calibratedWhite: 1.0, alpha: 1).setFill()
        let path = NSBezierPath(roundedRect: self.bounds, xRadius: 3, yRadius: 3)
        path.setClip()
        path.fill()
    }
    
}
