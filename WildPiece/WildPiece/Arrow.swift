//
//  DirectionPointer.swift
//  WildPiece
//
//  Created by Guocheng Xie on 10/2/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

class Arrow: SKShapeNode {
    let color: UInt = 0x00FFFF
    let opacity: CGFloat = 1.0
    
    init(startPoint :CGPoint, endPoint : CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) {
        super.init()
        let cgPath = self.pathWithArrowFromPoint(startPoint, endPoint: endPoint, tailWidth: tailWidth, headWidth: headWidth, headLength: headLength)
        self.path = cgPath
        self.lineWidth = 2.0
        self.zPosition = 0
        self.strokeColor = UIColor.UIColorFromRGB(color, alpha: opacity)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getAxisAlignedArrowPoints(inout points: Array<CGPoint>, forLength: CGFloat, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat ) {
        
        let tailLength = forLength - headLength
        points.append(CGPointMake(0, tailWidth/2))
        points.append(CGPointMake(tailLength, tailWidth/2))
        points.append(CGPointMake(tailLength, headWidth/2))
        points.append(CGPointMake(forLength, 0))
        points.append(CGPointMake(tailLength, -headWidth/2))
        points.append(CGPointMake(tailLength, -tailWidth/2))
        points.append(CGPointMake(0, -tailWidth/2))
    }
    
    func transformForStartPoint(startPoint: CGPoint, endPoint: CGPoint, length: CGFloat) -> CGAffineTransform{
        let cosine: CGFloat = (endPoint.x - startPoint.x)/length
        let sine: CGFloat = (endPoint.y - startPoint.y)/length
        
        return CGAffineTransformMake(cosine, sine, -sine, cosine, startPoint.x, startPoint.y)
    }
    
    
    func pathWithArrowFromPoint(startPoint :CGPoint, endPoint : CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> CGPath {
    
        let xdiff: Float = Float(endPoint.x) - Float(startPoint.x)
        let ydiff: Float = Float(endPoint.y) - Float(startPoint.y)
        let length: Float = hypotf(xdiff, ydiff)
        
        var points = [CGPoint]()
        self.getAxisAlignedArrowPoints(&points, forLength: CGFloat(length), tailWidth: tailWidth, headWidth: headWidth, headLength: headLength)
        
        var transform: CGAffineTransform = self.transformForStartPoint(startPoint, endPoint: endPoint, length:  CGFloat(length))
        
        var cgPath: CGMutablePathRef = CGPathCreateMutable()
        CGPathAddLines(cgPath, &transform, points, 7)
        CGPathCloseSubpath(cgPath)

        return cgPath
    }
    
    func shapeNodeWithArrowFromPoint (startPoint:CGPoint, endPoint: CGPoint, tailWidth: CGFloat, headWidth: CGFloat, headLength: CGFloat) -> SKShapeNode {
        let cgPath = pathWithArrowFromPoint(startPoint, endPoint: endPoint, tailWidth: tailWidth, headWidth: headWidth, headLength: headLength)
        let shape: SKShapeNode = SKShapeNode(path: cgPath)
        shape.physicsBody = nil
        return shape
    }
}