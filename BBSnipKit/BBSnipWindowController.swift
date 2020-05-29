//
//  BBSnipWindowController.swift
//  Main
//
//  Created by ACE_xW on 05/05/2020.
//  Copyright © 2020 ACE_xW. All rights reserved.
//

import Cocoa
import Foundation
import AppKit
import CoreGraphics

class BBSnipWindowController: NSWindowController {
    private var originSnipImage:NSImage?
    private var darkSnipImage:NSImage?
    private var snippedWindowRect = NSZeroRect
    private var draggedWindowRect = NSZeroRect
    private var startPoint = NSZeroPoint
    private var endPoint = NSZeroPoint
    private var lastRect = NSZeroRect
    private var rectStartPoint = NSZeroPoint
    private var rectEndPoint = NSZeroPoint
    private var dragDirection = 0
    private var rectDrawing = false
    private var linePoints:[NSPoint]?
    private var currentTextView:BBSnipTextView?
    private var textViews:[BBSnipTextView] = []
    var snipView:BBSnipView = BBSnipView()

    override func windowDidLoad() {
        super.windowDidLoad()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func startCapture(screen:NSScreen) {
        self.snapShot(screen: screen)
        if self.darkSnipImage != nil, self.window != nil, self.window!.contentView != nil, self.window!.screen != nil {
            self.window!.backgroundColor = NSColor(patternImage: self.darkSnipImage!)
            self.window!.setFrame(screen.frame, display: true, animate: false)
            self.snipView = self.window!.contentView as! BBSnipView
            (self.window as! BBSnipWindow).mouseDelegate = self
            self.snipView.addTrackingArea(rect: self.window!.screen!.frame)
            NotificationCenter.default.addObserver(self, selector: #selector(mouseMovedInMenuBar(notify:)), name: .BBSnipManagerMouseMovedInMenubar, object: nil)
            self.showWindow(nil)
            self.snipAppImage()
        }
    }
    
    @objc private func mouseMovedInMenuBar(notify:Notification) {
        if (notify.userInfo?["context"]) != nil {
            DispatchQueue.main.async {
                self.showWindow(nil)
                self.snipAppImage()
            }
        }
    }
    
    private func snipFinished() -> Void {
        for subView in self.snipView.subviews {
            if subView is BBSnipTextView {
                print("snipFinished text view frame \(subView.frame)")
                let startPoint = subView.frame.origin
                let endPoint = NSMakePoint(startPoint.x + subView.frame.size.width,startPoint.y + subView.frame.size.height)
                let textShape = BBSnipDrawShape(at: startPoint, to: endPoint, drawType: .text)
                textShape.text = (subView as! BBSnipTextView).string
                self.snipView.drawView.drawShapes.append(textShape)
            }
        }
        let rect = NSIntersectionRect(self.snippedWindowRect, self.window!.frame)
        self.originSnipImage?.lockFocus()
        self.snipView.drawView.drawFinishCommentInRec(imageRect: rect)
        let bitmapRep = NSBitmapImageRep(focusedViewRect: rect)
        self.originSnipImage?.unlockFocus()
        let cropData = bitmapRep?.representation(using: .png, properties: [.compressionFactor:1.0])
        if cropData != nil {
            let bitmap = NSImage(data: cropData!)
            if BBSnipManager.shared().debugMode {
                do {
                    print("save image to dir :\(NSTemporaryDirectory())")
                    try cropData?.write(to: URL(fileURLWithPath: NSTemporaryDirectory() + "test.jpeg"))
                    try self.originSnipImage?.tiffRepresentation(using: .jpeg, factor: 1.0)?.write(to: URL(fileURLWithPath: NSTemporaryDirectory() + "test2.jpeg"))
                } catch {
                    print(error)
                }
            }

            let pasteBoard = NSPasteboard.general
            pasteBoard.clearContents()
            pasteBoard.declareTypes([NSPasteboard.PasteboardType.png], owner: nil)
            pasteBoard.setData(cropData, forType: .png)
            //TODO: figure out why write objects cant be read by totok, but Dingtalk is ok
//            pasteBoard.writeObjects([bitmap!])
            BBSnipManager.shared().endCapture(image: bitmap)
        } else {
            BBSnipManager.shared().endCapture(image: nil)
        }
        self.window?.orderOut(nil)
    }
    
    private func snipAppImage() {
        let mouseLocation = NSEvent.mouseLocation
        let screenFrame = self.window!.screen!.frame
        self.snippedWindowRect = self.window!.screen!.frame
        var minArea = screenFrame.size.width * screenFrame.size.height
        for windowInfo in BBSnipManager.shared().windowsInfo {
            let sizeInfo = windowInfo[kCGWindowBounds as String] as! [String : Any]
            let windowHeight = sizeInfo["Height"] as! CGFloat
            let windowWidth = sizeInfo["Width"] as! CGFloat
            let windowLayer = windowInfo[kCGWindowLayer as String] as! Int
            let windowOrigX = sizeInfo["X"] as! CGFloat
            let windowOrigY = sizeInfo["Y"] as! CGFloat
            let windowRect = BBSnipUtility.windowRectToScreenRect(windowRect:  CGRect(x: windowOrigX, y: windowOrigY, width: windowWidth, height: windowHeight))
            if windowLayer < 0 {
                continue
            }
            if NSPointInRect(mouseLocation, windowRect) {
                if windowLayer == 0 {
                    self.snippedWindowRect = windowRect
                    break
                } else {
                    let area = windowRect.size.width * windowRect.size.height
                    if area < minArea {
                        self.snippedWindowRect = windowRect
                        minArea = area
                        break
                    }
                }
            }
        }
        if NSPointInRect(mouseLocation, screenFrame) {
            self.drawView(self.originSnipImage)
        } else {
            self.drawView(nil)
            NotificationCenter.default.post(name: Notification.Name.BBSnipManagerMouseMovedInMenubar,object: nil, userInfo: ["context":self] )
        }
    }
    
    private func drawView(_ image:NSImage?) {
        self.snippedWindowRect = NSIntersectionRect(self.snippedWindowRect, self.window!.frame)
        if image == nil, self.lastRect == self.snippedWindowRect {
            return
        }

        if self.window != nil {
            DispatchQueue.main.async {
                self.snipView.image = image
                let rect = self.window?.convertFromScreen(self.snippedWindowRect)
                self.snipView.drawRect = rect!
                self.snipView.needsDisplay = true
                self.lastRect = self.snippedWindowRect
            }
        }
    }
    
    private func setClickBeahvior() {
        self.snipView.toolbar.onClick = { [weak self] tag in
            self?.stopEditText()
            switch tag {
            case .rect:
                BBSnipManager.shared().snipDrawType = .rect
                BBSnipManager.shared().snipState = .edit
                self?.snipView.prepareForDrawObject(drawType: .rect)
                self?.snipView.needsDisplay = true
                break
            case .ellipse:
                BBSnipManager.shared().snipDrawType = .ellipse
                BBSnipManager.shared().snipState = .edit
                self?.snipView.prepareForDrawObject(drawType: .ellipse)
                self?.snipView.needsDisplay = true
                break
            case .arrow:
                BBSnipManager.shared().snipDrawType = .arrow
                BBSnipManager.shared().snipState = .edit
                self?.snipView.prepareForDrawObject(drawType: .arrow)
                self?.snipView.needsDisplay = true
                break
            case .text:
                BBSnipManager.shared().snipDrawType = .text
                BBSnipManager.shared().snipState = .edit
                self?.snipView.prepareForDrawObject(drawType: .text)
                self?.snipView.needsDisplay = true
                break
            case .pen:
                BBSnipManager.shared().snipDrawType = .line
                BBSnipManager.shared().snipState = .edit
                self?.snipView.prepareForDrawObject(drawType: .line)
                self?.snipView.needsDisplay = true
                break
            case .cancel:
                BBSnipManager.shared().endCapture(image: nil)
                break
            case .ok:
                self?.snipFinished()
                break
            default:
                break
            }
        }
    }
    
    private func stopEditText () {
        if self.currentTextView?.superview != nil {
            self.window?.makeFirstResponder(nil)
            for subView in self.snipView.subviews.reversed() {
                if subView is BBSnipTextView {
                    let textView = subView as! BBSnipTextView
                    if textView.string.count < 1 {
                        textView.removeFromSuperview()
                    }
                }
            }
//            self.rectDrawing = false
//            self.rectEndPoint = NSMakePoint(self.rectStartPoint.x + self.currentTextView!.frame.size.width, self.rectStartPoint.y - self.currentTextView!.frame.size.height)
//            self.snipView.drawView.drawObjects.append(BBSnipDrawShape(at: self.rectStartPoint, to: self.rectEndPoint, text: self.currentTextView!.string))
//            self.snipView.drawView.needsDisplay = true
//            self.snipView.setNeedsDisplay(self.window!.convertFromScreen(self.snippedWindowRect))
//            return
        }
    }
        
    private func snapShot(screen:NSScreen) {
        let image = BBSnipUtility.caputreScreen(screen)
        let rect = screen.frame
        if image != nil {
            self.originSnipImage = NSImage(cgImage: image!, size: rect.size)
            self.darkSnipImage = NSImage(cgImage: image!, size: rect.size)
            guard self.originSnipImage != nil,self.darkSnipImage != nil else {
                return
            }
            let imageBounds = NSMakeRect(0, 0, self.originSnipImage!.size.width, self.originSnipImage!.size.height)
            self.darkSnipImage?.lockFocus()
            NSColor(calibratedWhite: 0, alpha: 0.65).set()
            NSBezierPath(rect: imageBounds).fill()
            self.darkSnipImage?.unlockFocus()
        }
    }
    
    private func generateTextView() -> BBSnipTextView {
        let textView = BBSnipTextView(frame: NSZeroRect)
        textView.backgroundColor = NSColor.black
        textView.wantsLayer = true
        textView.font = NSFont.systemFont(ofSize: 14)
        textView.layer?.cornerRadius = 3
        textView.layer?.borderColor = NSColor.white.cgColor
        textView.layer?.borderWidth = 1
        textView.font = NSFont.systemFont(ofSize: 14)
        textView.textColor = NSColor.white
        textView.insertionPointColor = NSColor.white
        textView.textContainerInset = CGSize(width: 3, height: 3)
        textView.setSelectedRange(NSMakeRange(0, 0))
        textView.focusRingType = .exterior
        textView.restrictBorder = self.snippedWindowRect
        textView.layoutManager?.ensureLayout(for: textView.textContainer!)
        return textView
    }
}

extension BBSnipWindowController:NSWindowDelegate,BBSnipMouseDelegate{
    func onMouseDown(event: NSEvent) {
        let curState = BBSnipManager.shared().snipState
        print("- mouseDown - currentState \(curState) -")
        if event.clickCount == 2 {
            if curState != .highlight {
                self.snipFinished()
                return
            }
        }
        if curState == .highlight {
            BBSnipManager.shared().snipState = .firstMouseDown
            self.startPoint = NSEvent.mouseLocation
            self.setClickBeahvior()
//            self.snipView.showToolbar()
        } else if curState == .adjustSelectedRect {
            self.startPoint = NSEvent.mouseLocation
            self.snippedWindowRect = BBSnipUtility.uniformRect(rect: self.snippedWindowRect)
            self.draggedWindowRect = self.snippedWindowRect
            self.dragDirection = BBSnipUtility.dragDirectionFromPoint(mousePoint: NSEvent.mouseLocation, rect: self.draggedWindowRect)
        }
        
        if curState != .edit {
            self.snipView.hideToolbar()
        } else {
            let mouseLocation = NSEvent.mouseLocation
            if NSPointInRect(mouseLocation, self.snippedWindowRect) {
                self.stopEditText()
                self.rectStartPoint = NSEvent.mouseLocation
                self.rectDrawing = true
                self.snipView.onMouseDown(event: event)
                if BBSnipManager.shared().snipDrawType == .text {
                    let textView = self.generateTextView()
                    self.currentTextView = textView
                    self.textViews.append(textView)
                    self.snipView.addSubview(self.currentTextView!)
                    var initRect = NSMakeRect(mouseLocation.x, mouseLocation.y - 12, 120, 24)
                    var origin = initRect.origin
                    if NSMaxX(initRect) > NSMaxX(self.snippedWindowRect) - 2 {
                        origin.x = NSMaxX(snippedWindowRect) - NSWidth(initRect) - 2
                    }
                    if NSMaxY(initRect) > NSMaxY(self.snippedWindowRect) - 2 {
                        origin.y = NSMaxY(self.snippedWindowRect) - NSHeight(initRect) - 2
                    }
                    if NSMinX(initRect) < NSMinX(self.snippedWindowRect) - 2 {
                        origin.x = NSMinX(self.snippedWindowRect) - 2
                    }
                    if NSMinY(initRect) < NSMinY(snippedWindowRect) - 2 {
                        origin.y = NSMinY(snippedWindowRect) - 2
                    }
                    initRect.origin = origin
                    self.currentTextView!.frame = initRect
                
                    self.rectStartPoint = NSMakePoint(mouseLocation.x, mouseLocation.y - 12 + 24)
                    self.currentTextView!.setSelectedRange(NSMakeRange(0, 0))
                    self.window?.makeFirstResponder(self.currentTextView)
                }
            } else {
                print("out side")
            }
        }
    }
    
    func onMouseUp(event: NSEvent) {
        let state = BBSnipManager.shared().snipState
        if state == .readyAdjust || state == .firstMouseDown {
            BBSnipManager.shared().snipState = .adjustSelectedRect
            self.snipView.needsDisplay = true
        }
        if state != .edit {
            self.snipView.showToolbar()
            self.snipView.needsDisplay = true
        } else {
            if self.rectDrawing {
                self.snipView.onMouseUp(event: event)
                self.rectDrawing = false
//                self.rectEndPoint = NSEvent.mouseLocation
//                if drawType == .line {
//        //                    ADESnipDrawObject(points: <#T##[NSPoint]#>, drawType: <#T##BBSnipDrawType#>)
//        //                    self.snipView.drawView.drawObjects.append(<#T##newElement: ADESnipDrawObject##ADESnipDrawObject#>)
//                } else {
////                    self.snipView.drawView.drawShapes.append(BBSnipDrawShape(at: self.rectStartPoint, to: self.rectEndPoint, drawType: BBSnipManager.shared().snipDrawType))
//                }
//                self.snipView.setNeedsDisplay((self.window?.convertFromScreen(self.snippedWindowRect))!)
            }
        }
    }
    
    func onMouseDragged(event: NSEvent) {
        let state = BBSnipManager.shared().snipState
        switch state {
        case .readyAdjust, .firstMouseDown:
            BBSnipManager.shared().snipState = .readyAdjust
            self.endPoint = NSEvent.mouseLocation
            self.snippedWindowRect = NSUnionRect(NSMakeRect(self.startPoint.x, self.startPoint.y, 1, 1), NSMakeRect(self.endPoint.x, self.endPoint.y, 1, 1))
            self.snippedWindowRect = NSIntersectionRect(self.snippedWindowRect, self.window!.frame);
            self.drawView(self.originSnipImage)
            break
        case .edit:
            if self.rectDrawing {
                self.snipView.onMouseDrag(event: event)
                self.rectEndPoint = NSEvent.mouseLocation
                if BBSnipManager.shared().snipDrawType == .line {
                    
                } else {
                    self.snipView.drawView.drawShape = BBSnipDrawShape(at: self.rectStartPoint, to: self.rectEndPoint, drawType: BBSnipManager.shared().snipDrawType)
                }
                self.snipView.drawView.needsDisplay = true
            }
            break
        case .adjustSelectedRect:
            if self.dragDirection == -1 {
                return
            }
            self.snipView.hideToolbar()
            let mouseLocation = NSEvent.mouseLocation
            self.endPoint = mouseLocation
            let deltaX = self.endPoint.x - self.startPoint.x
            let deltaY = self.endPoint.y - self.startPoint.y
            var rect = self.draggedWindowRect
            switch self.dragDirection {
            case 0:
                rect.origin.x = rect.origin.x + deltaX
                rect.size.width = rect.size.width - deltaX
                rect.size.height = rect.size.height + deltaY
                break
            case 1:
                rect.size.height = rect.size.height + deltaY
                break
            case 2:
                rect.size.width = rect.size.width + deltaX
                rect.size.height = rect.size.height + deltaY
                break
            case 3:
                rect.origin.x = rect.origin.x + deltaX
                rect.size.width = rect.size.width - deltaX
                break
            case 4:
                rect.size.width = rect.size.width + deltaX
                break
            case 5:
                rect.origin.x = rect.origin.x + deltaX
                rect.origin.y = rect.origin.y + deltaY
                rect.size.width = rect.size.width - deltaX
                rect.size.height = rect.size.height - deltaY
                break
            case 6:
                rect.origin.y = rect.origin.y + deltaY
                rect.size.height = rect.size.height - deltaY
                break
            case 7:
                rect.origin.y = rect.origin.y + deltaY
                rect.size.width = rect.size.width + deltaX
                rect.size.height = rect.size.height - deltaY
                break
            case 8:
                rect = NSOffsetRect(rect, self.endPoint.x - self.startPoint.x, self.endPoint.y - self.startPoint.y)
                if !NSContainsRect(self.window!.frame, rect) {
                    let origin = self.window!.frame
                    if rect.origin.x < origin.origin.x {
                        rect.origin.x = origin.origin.x
                    }
                    if rect.origin.y < origin.origin.y {
                        rect.origin.y = origin.origin.y
                    }
                    if rect.origin.x > origin.origin.x + origin.size.width - rect.size.width {
                        rect.origin.x = origin.origin.x + origin.size.width - rect.size.width
                    }
                    if rect.origin.y > origin.origin.y + origin.size.height - rect.size.height {
                        rect.origin.y = origin.origin.y + origin.size.height - rect.size.height
                    }
                    self.endPoint = NSMakePoint(self.startPoint.x + rect.origin.x - self.draggedWindowRect.origin.x, self.startPoint.y + rect.origin.y - self.draggedWindowRect.origin.y)
                }
                break
            default:
                break
            }
            self.draggedWindowRect = rect;
            if rect.size.width == 0 {
                rect.size.width = 1
            }
            if rect.size.height == 0 {
                rect.size.height = 1
            }
            self.snippedWindowRect = BBSnipUtility.uniformRect(rect: rect)
            self.startPoint = self.endPoint
            self.drawView(self.originSnipImage)
            break
        default:
            break
        }

    }
    
    func onMouseMoved(event: NSEvent) {
        if BBSnipManager.shared().snipState == .highlight {
            self.snipAppImage()
        } else {
            self.snipView.onMouseMove(event: event)
        }
    }
}
