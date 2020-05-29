//
//  BBSnipDrawView.swift
//  BBSnipKit
//
//  Created by ACE_xW on 05/05/2020.
//  Copyright © 2020 ACE_xW. All rights reserved.
//

import Cocoa

class BBSnipDrawView: NSView {
    var drawShapes:[BBSnipDrawShape] = []
    var drawShape:BBSnipDrawShape?
    var trackingArea:NSTrackingArea?
    var shapeSelectedHandler:((_ shape: BBSnipDrawShape?) -> ())?
    var preVertices: [NSPoint]?
    var currentDrawType:BBSnipDrawType = .rect
    var currentShapeTool:BBSnipDrawShapTool? {
        didSet {
            if currentShapeTool == nil {
                self.shapeSelectedHandler?(nil)
            }
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - Mouse Event -
    public func onMouseDown(event:NSEvent) {
        print("BBSnipDrawView | onMouseDown | enter")
        var point:NSPoint = self.convert(event.locationInWindow, from: nil)
        point.x = floor(point.x)
        point.y = floor(point.y)
        if self.currentShapeTool != nil && self.currentShapeTool!.resizeHandleContainsPoint(point: point) {
            print("BBSnipDrawView | onMouseDown | resizeHandleContainsPoint ")
            self.currentShapeTool!.mouseDown(event: event)
        } else {
            print("BBSnipDrawView | onMouseDown | none control point")
            var selectedShape:BBSnipDrawShape?
            for shape in self.drawShapes {
                if shape.containsPoint(point: point) {
                    print("BBSnipDrawView | onMouseDown | found selected shapge")
                    selectedShape = shape
                    break
                }
            }
            if self.currentShapeTool != nil && self.currentShapeTool!.shape !== selectedShape {
                self.currentShapeTool?.shape.selected = false
                self.needsDisplay = true
            }
            if selectedShape != nil {
                print("BBSnipDrawView | onMouseDown | select shape not null")
                for (index, shape) in self.drawShapes.enumerated() {
                    if shape == selectedShape {
                        let select = self.drawShapes.remove(at: index)
                        self.drawShapes.append(select)
                        break
                    }
                }
                selectedShape!.selected = true
                self.currentShapeTool = BBSnipDrawShapTool.toolsForShape(shape: selectedShape!, view: self)
                NSCursor.closedHand.push()
                self.needsDisplay = true
                self.shapeSelectedHandler?(self.currentShapeTool!.shape)
            } else {
                print("BBSnipDrawView | onMouseDown | select shape null")
                let shape = BBSnipDrawShape(self.currentDrawType)
                self.drawShapes.append(shape)
                self.currentShapeTool = BBSnipDrawShapTool.toolsForShape(shape: shape, view: self)
            }
        }
        self.currentShapeTool?.mouseDown(event: event)
        print("BBSnipDrawView | onMouseDown | exit")
    }
    
    public func onMouseUp(event:NSEvent) {
        print("BBSnipDrawView | onMouseUp | enter")
        NSCursor.pop()
        self.currentShapeTool?.mouseUp(event: event)
        if let shape = self.currentShapeTool?.shape {
            if shape.vertices.count < 2 {
                print("BBSnipDrawView | onMouseUp | vertices count < 2")
                self.drawShapes.removeLast()
                self.currentShapeTool = nil
            } else {
                print("BBSnipDrawView | onMouseUp | vertices count >= 2")
                if !shape.selected {
                    self.shapeSelectedHandler?(shape)
                }
                shape.selected = true
            }
        } else {
            print("BBSnipDrawView | onMouseUp | shape is null")
        }
        print("BBSnipDrawView | onMouseUp | exit")

    }
    
    public func onMouseDrag(event:NSEvent) {
        print("BBSnipDrawView | onMouseDrag | enter")
        self.currentShapeTool?.mouseDragged(event: event)
        self.needsDisplay = true
        print("BBSnipDrawView | onMouseDrag | exit")
    }
    
    public func onMouseMove(event:NSEvent) {
//        print("BBSnipDrawView | onMouseMove | enter")

        let point = self.convert(event.locationInWindow, from: nil)
        if let shape = self.currentShapeTool?.shape {
            if shape.selected {
//                print("BBSnipDrawView | onMouseMove | shape selected")
                if self.currentShapeTool!.resizeHandleContainsPoint(point: point) {
                    print("BBSnipDrawView | onMouseMove | resizeHandleContainsPoint")
                    if NSCursor.currentSystem != NSCursor.crosshair {
                        NSCursor.pop()
                    }
                    NSCursor.crosshair.push()
                } else if shape.containsPoint(point: point) {
                    print("BBSnipDrawView | onMouseMove | shape contains point")
                    if NSCursor.currentSystem != NSCursor.openHand {
                        NSCursor.pop()
                    }
                    NSCursor.openHand.push()
                } else {
                    NSCursor.pop()
                }
            } else {
                NSCursor.pop()
            }
        } else {
//            print("BBSnipDrawView | onMouseMove | shape is null")
            NSCursor.pop()
        }
//        print("BBSnipDrawView | onMouseMove | exit")
    }
    
    // MARK: - draw -
    
    override func draw(_ dirtyRect: NSRect) {
        print("BBSnipDrawView | draw | enter")
        super.draw(dirtyRect)
//        if BBSnipManager.shared().snipState == .edit {
//            self.drawSnipObjectInRect(imageRect: self.bounds)
//            if self.drawShape != nil {
//                self.drawObject(drawInfo: self.drawShape!, inBackground: false)
//            }
//        }
        
        if self.drawShapes.count == 0 {
            print("BBSnipDrawView | draw | drawShape empty")
            return
        }
        
        let graphicPort = NSGraphicsContext.current!.graphicsPort
        let context = Unmanaged<CGContext>.fromOpaque(UnsafeRawPointer(graphicPort)).takeUnretainedValue()
        context.setStrokeColor(NSColor.red.cgColor)
        
        func innerFuncDrawResizeHandler(rect:NSRect) {
            print("BBSnipDrawView | draw | innerFuncDrawResizeHandler")
            context.setFillColor(NSColor.white.cgColor)
            context.setStrokeColor(NSColor.red.cgColor)
            context.setLineWidth(2.0)
            context.addEllipse(in: rect)
            context.drawPath(using: CGPathDrawingMode.fillStroke)
        }
        
        print("BBSnipDrawView | draw | draw \(self.drawShapes.count) shape")
        for shape in self.drawShapes {
            print("BBSnipDrawView | draw | shape:\(shape.drawType) | \(Unmanaged.passUnretained(shape as AnyObject).toOpaque())")
            if shape.vertices.count < 2 {
                print("BBSnipDrawView | draw | shape  \(Unmanaged.passUnretained(shape as AnyObject).toOpaque()) vertices count: \(shape.vertices.count) illigle")
                continue
            }
            context.setStrokeColor(shape.borderColor.cgColor)
            context.setFillColor(shape.fillColor.cgColor)
            context.setLineWidth(CGFloat(shape.lineWidth))
            if shape.drawType == .line {
                
            } else if shape.drawType == .rect {
                print("BBSnipDrawView | draw | current shape \(shape.drawType)")
                let p1 = shape.vertices[0]
                let p2 = shape.vertices[1]
                
                let rect: CGRect = CGRect(origin:CGPoint(x:min(p1.x, p2.x), y:min(p1.y, p2.y)), size:CGSize(width:abs(p1.x - p2.x), height:abs(p1.y - p2.y)))
                
                context.fill(rect)
                context.stroke(rect)

                if shape.selected {
                    innerFuncDrawResizeHandler(rect: BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.minX, y:rect.minY)))
                    innerFuncDrawResizeHandler(rect: BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.minX, y:rect.maxY)))
                    innerFuncDrawResizeHandler(rect: BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.maxX, y:rect.minY)))
                    innerFuncDrawResizeHandler(rect: BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.maxX, y:rect.maxY)))
                }
                
            } else if shape.drawType == .ellipse {
                let p1 = shape.vertices[0]
                let p2 = shape.vertices[1]
                let rect: CGRect = CGRect(origin:CGPoint(x:min(p1.x, p2.x), y:min(p1.y, p2.y)), size:CGSize(width:abs(p1.x - p2.x), height:abs(p1.y - p2.y)))
                
                context.addEllipse(in: rect)
                context.drawPath(using: CGPathDrawingMode.fillStroke)
                
                if shape.selected {
                    innerFuncDrawResizeHandler(rect: BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.minX, y:rect.minY)))
                    innerFuncDrawResizeHandler(rect: BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.minX, y:rect.maxY)))
                    innerFuncDrawResizeHandler(rect: BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.maxX, y:rect.minY)))
                    innerFuncDrawResizeHandler(rect: BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.maxX, y:rect.maxY)))
                }
            } else if shape.drawType == .text {
//                print("BBSnipDrawView | draw | current shape \(shape.drawType)")
//
//                let p1 = shape.vertices[0]
//                let p2 = shape.vertices[1]
//                let rect: CGRect = CGRect(origin:CGPoint(x:min(p1.x, p2.x), y:min(p1.y, p2.y)), size:CGSize(width:abs(p1.x - p2.x), height:abs(p1.y - p2.y)))
//
//                context.setStrokeColor(NSColor.red.cgColor)
//                context.setTextDrawingMode(.fill)
//                context.setFillColor(NSColor.clear.cgColor)
//                context.beginPath()
//                context.addRect(rect)
//                context.strokePath()
//                context.setFillColor(.black)
//                context.textMatrix = .identity
//
//                var font = CTFontCreateWithName("Helvetica" as CFString, 48, nil)
//                var glyph = CTFontGetGlyphWithName(font, "A" as CFString)
//                var glyph1Position = rect.origin
//
//                CTFontDrawGlyphs(font, &glyph, &glyph1Position, 1, context)
//                if shape.selected {
//                    innerFuncDrawResizeHandler(rect: BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.minX, y:rect.minY)))
//                    innerFuncDrawResizeHandler(rect: BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.minX, y:rect.maxY)))
//                    innerFuncDrawResizeHandler(rect: BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.maxX, y:rect.minY)))
//                    innerFuncDrawResizeHandler(rect: BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.maxX, y:rect.maxY)))
//                }
            }
        }
        print("BBSnipDrawView | draw | exit")
    }
    
    private func rectFromScreen(rect:NSRect) -> NSRect {
        var rectRet = self.window!.convertFromScreen(rect)
        rectRet.origin.x = rectRet.origin.x - self.frame.origin.x
        rectRet.origin.y = rectRet.origin.y - self.frame.origin.y
        return rectRet
    }
    
    public func drawFinishCommentInRec(imageRect:NSRect) {
        print("BBSnipDrawView::drawFinishCommentInRec | enter")
        let path = NSBezierPath(rect: imageRect)
        path.addClip()
        NSColor.red.set()
        print("BBSnipDrawView::drawFinishCommentInRec | total shapes :\(self.drawShapes.count)")
        for shape in self.drawShapes {
            if shape.drawType == .text {
                print("BBSnipDrawView::drawFinishCommentInRec | add text vertices startPoint :\(shape.startPoint) endPoint:\(shape.endPoint)")
                shape.vertices.append(NSPointToCGPoint(self.convert(shape.startPoint, from: nil)))
                shape.vertices.append(NSPointToCGPoint(self.convert(shape.endPoint, from: nil)))
            }
            print("BBSnipDrawView::drawFinishCommentInRec | draw shape:\(shape.drawType) \(Unmanaged.passUnretained(shape as AnyObject).toOpaque())")
            if shape.vertices.count >= 2 {
                print("BBSnipDrawView::drawFinishCommentInRec | shape:\(shape.drawType) \(Unmanaged.passUnretained(shape as AnyObject).toOpaque()) vertices >= 2")
                self.drawShape(shape: shape, inBackground: true)
            } else {
                print("BBSnipDrawView::drawFinishCommentInRec | \(shape.drawType) \(Unmanaged.passUnretained(shape as AnyObject).toOpaque()) vertices count:\(shape.vertices.count)")
            }
        }
        print("BBSnipDrawView::drawFinishCommentInRec | exit")
    }
    
    private func drawShape(shape:BBSnipDrawShape, inBackground:Bool) -> Void {
        print("BBSnipDrawView::drawShape | enter")
        let p1 = shape.vertices[0]
        let p2 = shape.vertices[1]
        var rect: CGRect = CGRect(origin:CGPoint(x:min(p1.x, p2.x), y:min(p1.y, p2.y)), size:CGSize(width:abs(p1.x - p2.x), height:abs(p1.y - p2.y)))
        print("BBSnipDrawView::drawShape | draw \(shape.drawType) rect:\(rect)")

        if inBackground {
            rect =  self.convert(rect, to: nil)
            print("BBSnipDrawView::drawShape | draw in background converFromScreen: \(rect)")
        } else {
            rect = self.rectFromScreen(rect: rect)
            print("BBSnipDrawView::drawShape | draw in forground converFromScreen: \(rect)")
        }
        
        let path = NSBezierPath()
        path.lineWidth = 4
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        switch shape.drawType {
        case .rect:
            rect = BBSnipUtility.uniformRect(rect: rect)
            path.appendRect(rect)
            path.stroke()
            break
        case .arrow:
            break
        case .ellipse:
//            rect = BBSnipUtility.uniformRect(rect: rect)
//            path.appendOval(in: rect)
//            path.stroke()
            break
        case .line:
 
            break
        case .text:
            if let drawText = shape.text {
                print("BBSnipDrawView::drawShape | draw text")
                rect = BBSnipUtility.uniformRect(rect: rect)
                let drawText = NSMutableAttributedString(string: drawText, attributes: [NSAttributedString.Key.font : NSFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor:NSColor.white, NSAttributedString.Key.backgroundColor:NSColor.black])
                drawText.draw(in: rect)
            }
            break
        case .none:
            break
        }
    }
}
