//
//  BBSnipShapeTool.swift
//  BBSnipKit
//
//  Created by ACE_xW on 12/05/2020.
//  Copyright © 2020 ACE_xW. All rights reserved.
//

import Foundation
import Cocoa

class BBSnipDrawShapTool {
    class func toolsForShape(shape:BBSnipDrawShape, view:NSView) -> BBSnipDrawShapTool {
        switch shape.drawType {
        case .rect:
            return BBSnipRectShapeTool(shape: shape, view: view)
        case .ellipse:
            return BBSnipEllipseShapeTool(shape: shape, view: view)
        case .arrow:
            return BBSnipArrowShapeTool(shape: shape, view: view)
        case .line:
            return BBSnipLineShapeTool(shape: shape, view: view)
        case .text:
            return BBSnipTextShapeTool(shape: shape, view: view)
        case .none:
            return BBSnipNoneShapeTool(shape: shape, view: view)
        }
        
    }
    
    var associatedView:NSView
    var shape:BBSnipDrawShape
    
    class var handleSize:CGFloat {
        return 10
    }
    
    class var minimumSize:CGFloat {
        return 10
    }
    
    init(shape:BBSnipDrawShape, view:NSView) {
        self.associatedView = view
        self.shape = shape
        print("BBSnipDrawShapTool | init | shape:\(shape.drawType) | \(Unmanaged.passUnretained(shape as AnyObject).toOpaque()) | self.shape \(Unmanaged.passUnretained(self.shape as AnyObject).toOpaque())")

    }
    
    func mouseDown(event: NSEvent) {
       assert(false, "subclass must implement")
    }

    func mouseDragged(event: NSEvent) {
       assert(false, "subclass must implement")
    }

    func mouseUp(event: NSEvent) {
       assert(false, "subclass must implement")
    }
    
    func resizeHandleContainsPoint(point: NSPoint) -> Bool {
         assert(false, "subclass must implement")
         return false
    }
    
    class func resizeHandleRectForPoint(point: NSPoint) -> CGRect {
       return CGRect(x: point.x - handleSize/2, y: point.y - handleSize/2, width: handleSize, height: handleSize)
    }
}

class BBSnipRectShapeTool:BBSnipDrawShapTool {
    var dragged = false
    var resizeCorner = RectCorner.None
    var distance1 = NSSizeToCGSize(NSZeroSize)
    var distance2 = NSSizeToCGSize(NSZeroSize)
    
    enum RectCorner {
        case BottomLeft
        case Bottom
        case BottomRight
        case TopLet
        case Top
        case TopRight
        case MiddleLeft
        case MiddleRight
        case None
    }
    
    override func resizeHandleContainsPoint(point: NSPoint) -> Bool {
        return resizeCornerForPoint(point: point) != RectCorner.None
    }

    func resizeCornerForPoint(point:NSPoint) -> RectCorner {
        let rect = shape.presentedRect
        if BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.minX, y:rect.minY)).contains(point) {
           return .BottomLeft
        } else if BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.minX, y:rect.maxY)).contains(point) {
           return .TopLet
        } else if BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.maxX, y:rect.minY)).contains(point) {
           return .BottomRight
        } else if BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.maxX, y:rect.maxY)).contains(point) {
           return .TopRight
//        } else if BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.maxX, y:rect.maxY)).contains(point) {
//            return .Top
//        } else if BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.maxX, y:rect.maxY)).contains(point) {
//            return .Bottom
//        } else if BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.maxX, y:rect.maxY)).contains(point) {
//            return .MiddleLeft
//        } else if BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.maxX, y:rect.maxY)).contains(point) {
//            return .MiddleRight
        }
        return .None
    }
    
    override func mouseDown(event: NSEvent) {
        print("BBSnipRectShapeTool | mouseDown | enter | shape:\(shape.drawType) | vertices:\(shape.vertices.count)")
        var p: NSPoint = event.locationInWindow
        p = associatedView.convert(p, from:nil)

        resizeCorner = resizeCornerForPoint(point: p)
        if resizeCorner != RectCorner.None {
            print("BBSnipRectShapeTool | mouseDown | resizeCorner = \(resizeCorner) | shape:\(shape.drawType) | vertices:\(shape.vertices.count)")
            
        } else if shape.containsPoint(point: p) {
            print("BBSnipRectShapeTool | mouseDown | shape containes point | can drag | shape:\(shape.drawType) | vertices:\(shape.vertices.count)")
            dragged = true
            let p1 = shape.vertices[0]
            let p2 = shape.vertices[1]
            p.x = floor(p.x)
            p.y = floor(p.y)
            distance1 = CGSize(width:p.x - p1.x, height:p.y - p1.y)
            distance2 = CGSize(width:p.x - p2.x, height:p.y - p2.y)
        } else {
            print("BBSnipRectShapeTool | mouseDown | shape not containes point | can not drag | shape:\(shape.drawType) | vertices:\(shape.vertices.count)")
            p.x = floor(p.x)
            p.y = floor(p.y)
            shape.vertices = [p]
        }
        print("BBSnipRectShapeTool | mouseDown | enter | shape:\(shape.drawType) | vertices:\(shape.vertices.count)")
    }
        
    override func mouseDragged(event: NSEvent) {
        print("BBSnipRectShapeTool | mouseDragged | enter | shape:\(shape.drawType) | vertices:\(shape.vertices.count)")
        var p: NSPoint = event.locationInWindow
        p = associatedView.convert(p, from:nil)
        p.x = floor(p.x)
        p.y = floor(p.y)

        if resizeCorner != RectCorner.None {
            print("BBSnipRectShapeTool | mouseDragged | resizeCorner not none | shape:\(shape.drawType) | vertices:\(shape.vertices.count)")

            var rect = shape.presentedRect
            if resizeCorner == .BottomLeft {
                let maxX = rect.maxX
                let maxY = rect.maxY
                
                rect.size.width = maxX - p.x
                rect.size.height = maxY - p.y
                rect.origin = p
                
                if rect.size.width < BBSnipDrawShapTool.minimumSize {
                    rect.origin.x = maxX - BBSnipDrawShapTool.minimumSize
                    rect.size.width = BBSnipDrawShapTool.minimumSize
                }
                
                if rect.size.height < BBSnipDrawShapTool.minimumSize {
                    rect.origin.y = maxY - BBSnipDrawShapTool.minimumSize
                    rect.size.height = BBSnipDrawShapTool.minimumSize
                }
                
            } else if resizeCorner == .BottomRight {
        //                let maxX = rect.maxX
                let maxY = rect.maxY

                rect.origin.y = p.y
                rect.size.width = p.x - rect.origin.x
                rect.size.height = maxY - p.y
                
                if rect.size.width < BBSnipDrawShapTool.minimumSize {
                    rect.size.width = BBSnipDrawShapTool.minimumSize
                }
                if rect.size.height < BBSnipDrawShapTool.minimumSize {
                    rect.size.height = BBSnipDrawShapTool.minimumSize
                    rect.origin.y = maxY - BBSnipDrawShapTool.minimumSize
                }
                
            } else if resizeCorner == .TopLet {
                let maxX = rect.maxX
        //                let maxY = rect.maxY

                rect.origin.x = p.x
                rect.size.width = maxX - p.x
                rect.size.height = p.y - rect.origin.y
                
                if rect.size.width < BBSnipDrawShapTool.minimumSize {
                    rect.size.width = BBSnipDrawShapTool.minimumSize
                    rect.origin.x = maxX - BBSnipDrawShapTool.minimumSize
                }
                if rect.size.height < BBSnipDrawShapTool.minimumSize {
                    rect.size.height = BBSnipDrawShapTool.minimumSize
                }

            } else if resizeCorner == .TopRight {
                rect.size.width = p.x - rect.origin.x
                rect.size.height = p.y - rect.origin.y
                
                if rect.size.width < BBSnipDrawShapTool.minimumSize {
                    rect.size.width = BBSnipDrawShapTool.minimumSize
                }
                if rect.size.height < BBSnipDrawShapTool.minimumSize {
                    rect.size.height = BBSnipDrawShapTool.minimumSize
                }
            }
            shape.vertices[0] = rect.origin
            shape.vertices[1] = NSPoint(x:rect.maxX, y:rect.maxY)
            
        } else if dragged {
            print("BBSnipRectShapeTool | mouseDragged | dragging | shape:\(shape.drawType) | vertices:\(shape.vertices.count)")

            shape.vertices[0].x = p.x - distance1.width
            shape.vertices[0].y = p.y - distance1.height
            
            shape.vertices[1].x = p.x - distance2.width
            shape.vertices[1].y = p.y - distance2.height
            
        } else {
            if shape.vertices.count < 2 {
                shape.vertices.append(p)
            } else {
                shape.vertices[1] = p
            }
            print("BBSnipRectShapeTool | mouseDragged | create vertice | shape:\(shape.drawType) | vertices:\(shape.vertices.count)")
        }
        print("BBSnipRectShapeTool | mouseDragged | exit | shape:\(shape.drawType) | vertices:\(shape.vertices.count) | \(Unmanaged.passUnretained(shape as AnyObject).toOpaque())")

    }
    
    override func mouseUp(event: NSEvent) {
        print("BBSnipRectShapeTool | mouseUp | enter | shape:\(shape.drawType) | vertices:\(shape.vertices.count)")
        if shape.vertices.count > 1 {
            print("BBSnipRectShapeTool | mouseUp | shape:\(shape.drawType) | vertices count:\(shape.vertices.count)")
            var rect = shape.presentedRect
            if rect.width < BBSnipDrawShapTool.minimumSize || rect.height < BBSnipDrawShapTool.minimumSize {
                rect.size.width = max(BBSnipDrawShapTool.minimumSize, rect.width)
                rect.size.height = max(BBSnipDrawShapTool.minimumSize, rect.height)
                shape.vertices = [ rect.origin, NSPoint(x:rect.maxX, y:rect.maxY) ]
            }
        }
        dragged = false
        print("BBSnipRectShapeTool | mouseUp | exit | shape:\(shape.drawType) | vertices:\(shape.vertices.count)")
    }
}

class BBSnipEllipseShapeTool:BBSnipDrawShapTool {
    override init(shape: BBSnipDrawShape, view: NSView) {
        super.init(shape: shape, view: view)
    }
    
    var dragged = false
        var resizeCorner = RectCorner.None
        var distance1 = NSSizeToCGSize(NSZeroSize)
        var distance2 = NSSizeToCGSize(NSZeroSize)
        
        enum RectCorner {
            case LowerLeft
            case LowerRight
            case UpperLeft
            case UpperRight
            case None
        }
        
        func resizeCornerForPoint(point: NSPoint) -> RectCorner {
            let rect = shape.presentedRect
            
            if BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.minX, y:rect.minY)).contains(point) {
                return .LowerLeft
                
            } else if BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.minX, y:rect.maxY)).contains(point) {
                return .UpperLeft
                
            } else if BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.maxX, y:rect.minY)).contains(point) {
                return .LowerRight
                
            } else if BBSnipDrawShapTool.resizeHandleRectForPoint(point: NSPoint(x:rect.maxX, y:rect.maxY)).contains(point) {
                return .UpperRight
            }
            
            return .None
        }
        
        override func resizeHandleContainsPoint(point: NSPoint) -> Bool {
            return resizeCornerForPoint(point: point) != RectCorner.None
        }
        
        override func mouseDown(event: NSEvent) {
            var p: NSPoint = event.locationInWindow
            p = associatedView.convert(p, from:nil)
            
            resizeCorner = resizeCornerForPoint(point: p)
            if resizeCorner != RectCorner.None {
                // for resizing
                
            } else if shape.containsPoint(point: p) {
                // move
                dragged = true
                
                let p1 = shape.vertices[0]
                let p2 = shape.vertices[1]
                
                p.x = floor(p.x)
                p.y = floor(p.y)
                distance1 = CGSize(width:p.x - p1.x, height:p.y - p1.y)
                distance2 = CGSize(width:p.x - p2.x, height:p.y - p2.y)
                
            } else {
                p.x = floor(p.x)
                p.y = floor(p.y)
                shape.vertices = [p]
            }
        }
        
        override func mouseDragged(event: NSEvent) {
            var p: NSPoint = event.locationInWindow
            p = associatedView.convert(p, from:nil)
            p.x = floor(p.x)
            p.y = floor(p.y)
            
            if resizeCorner != RectCorner.None {
                var rect = shape.presentedRect
                
                if resizeCorner == .LowerLeft {
                    let maxX = rect.maxX
                    let maxY = rect.maxY
                    
                    rect.size.width = maxX - p.x
                    rect.size.height = maxY - p.y
                    rect.origin = p
                    
                    if rect.size.width < BBSnipDrawShapTool.minimumSize {
                        rect.origin.x = maxX - BBSnipDrawShapTool.minimumSize
                        rect.size.width = BBSnipDrawShapTool.minimumSize
                    }
                    
                    if rect.size.height < BBSnipDrawShapTool.minimumSize {
                        rect.origin.y = maxY - BBSnipDrawShapTool.minimumSize
                        rect.size.height = BBSnipDrawShapTool.minimumSize
                    }
                    
                } else if resizeCorner == .LowerRight {
    //                let maxX = rect.maxX
                    let maxY = rect.maxY
                    
                    rect.origin.y = p.y
                    rect.size.width = p.x - rect.origin.x
                    rect.size.height = maxY - p.y
                    
                    if rect.size.width < BBSnipDrawShapTool.minimumSize {
                        rect.size.width = BBSnipDrawShapTool.minimumSize
                    }
                    if rect.size.height < BBSnipDrawShapTool.minimumSize {
                        rect.size.height = BBSnipDrawShapTool.minimumSize
                        rect.origin.y = maxY - BBSnipDrawShapTool.minimumSize
                    }
                    
                } else if resizeCorner == .UpperLeft {
                    let maxX = rect.maxX
    //                let maxY = rect.maxY
                    
                    rect.origin.x = p.x
                    rect.size.width = maxX - p.x
                    rect.size.height = p.y - rect.origin.y
                    
                    if rect.size.width < BBSnipDrawShapTool.minimumSize {
                        rect.size.width = BBSnipDrawShapTool.minimumSize
                        rect.origin.x = maxX - BBSnipDrawShapTool.minimumSize
                    }
                    if rect.size.height < BBSnipDrawShapTool.minimumSize {
                        rect.size.height = BBSnipDrawShapTool.minimumSize
                    }
                    
                } else if resizeCorner == .UpperRight {
                    rect.size.width = p.x - rect.origin.x
                    rect.size.height = p.y - rect.origin.y
                    
                    if rect.size.width < BBSnipDrawShapTool.minimumSize {
                        rect.size.width = BBSnipDrawShapTool.minimumSize
                    }
                    if rect.size.height < BBSnipDrawShapTool.minimumSize {
                        rect.size.height = BBSnipDrawShapTool.minimumSize
                    }
                }
                
                shape.vertices[0] = rect.origin
                shape.vertices[1] = NSPoint(x:rect.maxX, y:rect.maxY)
                
            } else if dragged {
                shape.vertices[0].x = p.x - distance1.width
                shape.vertices[0].y = p.y - distance1.height
                
                shape.vertices[1].x = p.x - distance2.width
                shape.vertices[1].y = p.y - distance2.height
                
            } else {
                // creating
                if shape.vertices.count < 2 {
                    shape.vertices.append(p)
                } else {
                    shape.vertices[1] = p
                }
            }
        }
        
        override func mouseUp(event: NSEvent) {
            if shape.vertices.count > 1 {
                var rect = shape.presentedRect
                if rect.width < BBSnipDrawShapTool.minimumSize || rect.height < BBSnipDrawShapTool.minimumSize {
                    // fix
                    rect.size.width = max(BBSnipDrawShapTool.minimumSize, rect.width)
                    rect.size.height = max(BBSnipDrawShapTool.minimumSize, rect.height)
                    shape.vertices = [ rect.origin, NSPoint(x:rect.maxX, y:rect.maxY) ]
                }
            }
            
            dragged = false
        }
}

class BBSnipNoneShapeTool:BBSnipDrawShapTool{
    override func mouseUp(event: NSEvent) {
        
    }
    
    override func mouseDown(event: NSEvent) {
        
    }
    
    override func mouseDragged(event: NSEvent) {
        
    }
}

class BBSnipArrowShapeTool:BBSnipDrawShapTool {
    
    override func mouseUp(event: NSEvent) {
        
    }
    
    override func mouseDown(event: NSEvent) {
        
    }
    
    override func mouseDragged(event: NSEvent) {
        
    }
}

class BBSnipLineShapeTool:BBSnipDrawShapTool {
    
    override func mouseDragged(event: NSEvent) {
        
    }
    
    override func mouseUp(event: NSEvent) {
        
    }
    
    override func mouseDown(event: NSEvent) {
        
    }
}

class BBSnipTextShapeTool:BBSnipDrawShapTool {
    
    override func mouseDown(event: NSEvent) {
        
    }
        
    override func mouseDragged(event: NSEvent) {

    }
    
    override func mouseUp(event: NSEvent) {
        
    }
}
