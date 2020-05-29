//
//  BBSnipManager.swift
//  Main
//
//  Created by ACE_xW on 04/05/2020.
//  Copyright © 2020 ACE_xW. All rights reserved.
//

import Foundation
import AppKit

public enum BBSnipState {
    case idle
    case highlight
    case firstMouseDown
    case readyAdjust
    case adjustSelectedRect
    case edit
    case done
}

public enum BBSnipDrawType{
    case rect
    case ellipse
    case arrow
    case line
    case text
    case none
}

public class BBSnipManager {
    public var debugMode = false
    private var windowsControllers:[NSWindowController] = []
    var windowsInfo:[[String:Any]] = []
    private var isWorking = false
    public var snipState:BBSnipState = .idle
    public var snipDrawType:BBSnipDrawType = .rect
    
    private static let sharedManager : BBSnipManager = {
        let instance = BBSnipManager()
        return instance
    }()
    
    private init() {
       
    }
    
    private func addNotificationListener() {
        NSWorkspace.shared.notificationCenter.addObserver(BBSnipManager.sharedManager, selector: #selector(self.spaceChanged), name: NSWorkspace.activeSpaceDidChangeNotification, object: NSWorkspace.shared)
        NotificationCenter.default.addObserver(BBSnipManager.sharedManager, selector: #selector(self.spaceChanged), name: NSApplication.didChangeScreenParametersNotification, object: nil)
    }
    
    public class func shared() -> BBSnipManager {
        return sharedManager
    }
    
    public func endCapture(image img:NSImage?) {
        if !self.isWorking {
            return
        }
        self.isWorking = false
        for eachController in self.windowsControllers {
            eachController.window?.orderOut(nil)
        }
        self.clearController()
        NotificationCenter.default.post(name: NSNotification.Name.BBSnipManagerCaptureEnd, object: nil, userInfo: img == nil ? nil : ["image":img!])
    }
    
    public func startCapture() {
        if self.isWorking {
            return
        }
        
//        let path = "\(Bundle.main.bundlePath)/Contents/Frameworks/BBSnipKit.framework/Resources/"
//        let curImage = NSImage(contentsOfFile: path + "ic_screenshot_mark.tiff")
//        if curImage != nil {
////            NSCursor.hide()
//            let cursor = NSCursor(image: curImage!, hotSpot: NSMakePoint(curImage!.size.width, curImage!.size.height))
//            cursor.set()
//        }

        self.isWorking = true
        if let windowInfo = CGWindowListCopyWindowInfo(.optionOnScreenOnly, kCGNullWindowID) as? [[ String : Any]] {
            self.windowsInfo.append(contentsOf: windowInfo)
        }
        
        for screen in NSScreen.screens {
            let snipWinController = BBSnipWindowController.init()
            let snipWin = BBSnipWindow.init(contentRect: screen.frame, styleMask: .nonactivatingPanel, backing: .buffered, defer: false, screen: screen)
            snipWinController.window = snipWin
            let snipView = BBSnipView.init(frame: NSMakeRect(0, 0, screen.frame.size.width, screen.frame.size.height))
            snipWin.contentView = snipView
            snipView.windowsInfo = windowsInfo
            snipView.debugMode = self.debugMode
            self.windowsControllers.append(snipWinController)
            self.snipState = .highlight
            snipWinController.startCapture(screen: screen)
        }
    }
    
    private func clearController() {
        if self.windowsControllers.count > 0 {
            self.windowsControllers.removeAll()
        }
        self.windowsInfo = []
    }
    
    @objc private func spaceChanged() {
        if self.isWorking {
            self.endCapture(image: nil)
        }
    }
}
