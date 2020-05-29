//
//  BBSnipDrawObject.swift
//  BBSnipKit
//
//  Created by ACE_xW on 05/05/2020.
//  Copyright © 2020 ACE_xW. All rights reserved.
//

import Foundation
import Cocoa

class BBSnipDrawShape:Equatable {
    var startPoint:NSPoint = NSZeroPoint
    var endPoint:NSPoint = NSZeroPoint
    var points:[NSPoint] = []
    var text:String?
    var drawType:BBSnipDrawType = .rect
    var selected:Bool = false
    var fillColor:NSColor = NSColor.clear
    var borderColor = NSColor.red
    var vertices:[NSPoint] = []
    var lineWidth = 4.0
    
    var presentedRect:CGRect {
        if vertices.count < 2 {
            return CGRect(x: 0, y: 0, width: 0, height: 0)
        }
        let p1 = vertices[0]
        let p2 = vertices[1]
        return CGRect(origin:CGPoint(x:min(p1.x, p2.x), y:min(p1.y, p2.y)), size:CGSize(width:abs(p1.x - p2.x), height:abs(p1.y - p2.y)))
    }
    
    init(_ type:BBSnipDrawType) {
        self.drawType = type
        self.lineWidth = 4.0
        self.fillColor = NSColor.clear
        self.borderColor = NSColor.red
    }
    
    func copy() -> BBSnipDrawShape {
        let copy = BBSnipDrawShape(self.drawType)
        copy.lineWidth = self.lineWidth
        copy.fillColor = self.fillColor
        copy.borderColor = self.borderColor
        copy.vertices = self.vertices
        copy.startPoint = self.startPoint
        copy.endPoint = self.endPoint
        return copy
    }
    
    func containsPoint(point: NSPoint) -> Bool {
        if (drawType == BBSnipDrawType.line) {
            if vertices.count != 2 {
                return false
            }

            let p1 = vertices[0]
            let p2 = vertices[1]
            let dx = p2.x - p1.x
            let dy = p2.y - p1.y
            let a = dx*dx + dy*dy
            let b = dx*(p1.x - point.x) + dy*(p1.y - point.y)
            var t = -b/a
            t = t < 0 ? 0 : t
            t = t > 1 ? 1 : t
            let cx = t*dx + p1.x
            let cy = t*dy + p1.y
            let distance = ((cx - point.x) * (cx - point.x) + (cy - point.y) * (cy - point.y))
            return distance < 50
        } else if (drawType == BBSnipDrawType.rect) {
            return presentedRect.contains(point)
        } else if (drawType == BBSnipDrawType.ellipse) {
            let bezierPath = NSBezierPath(ovalIn:presentedRect)
            return bezierPath.contains(point)
        }
        return false
    }

    static func ==(lhs: BBSnipDrawShape, rhs: BBSnipDrawShape) -> Bool {
        return (lhs.drawType == rhs.drawType) && (lhs.vertices == rhs.vertices) && (lhs.fillColor == rhs.fillColor) && (lhs.lineWidth == rhs.lineWidth) && (lhs.borderColor == rhs.borderColor) && (lhs.selected == rhs.selected)
    }

    static func !=(lhs: BBSnipDrawShape, rhs: BBSnipDrawShape) -> Bool {
        return !(lhs == rhs)
    }
    
    init(at start:NSPoint, to end:NSPoint, drawType type:BBSnipDrawType) {
        self.startPoint = start
        self.endPoint = end
        self.drawType = type
    }
    
    init(at start:NSPoint, to end:NSPoint, text:String) {
        self.startPoint = start
        self.endPoint = end
        self.text = text
        self.drawType = .text
    }
    
    init(points:[NSPoint], drawType type:BBSnipDrawType) {
        self.points = points
        self.drawType = type
    }
}
