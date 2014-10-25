//
//  Board.swift
//  WildPiece
//
//  Created by Kaiqi on 14/10/25.
//  Copyright (c) 2014年 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

class Board : SKShapeNode {

    let width : CGFloat
    let height : CGFloat
    let marginX: CGFloat = 0
    let marginY: CGFloat = 40
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(width : CGFloat, height : CGFloat){
        self.width = width
        self.height = height
        super.init()
        self.path = self.createVisiblePath()
        self.physicsBody = self.createPhysicsBody()
        self.strokeColor = UIColor.whiteColor()
    }
    
    func createVisiblePath() -> CGPath {
        var pathToDraw : CGMutablePathRef = CGPathCreateMutable()
        // border
        CGPathMoveToPoint(pathToDraw, nil, marginX, marginY);
        CGPathAddLineToPoint(pathToDraw, nil, marginX, height-marginY);
        CGPathAddLineToPoint(pathToDraw, nil, width-marginX, height-marginY);
        CGPathAddLineToPoint(pathToDraw, nil, width-marginX, marginY);
        CGPathAddLineToPoint(pathToDraw, nil, marginX, marginY);
        
        // center line
        CGPathMoveToPoint(pathToDraw, nil, 0, self.height);
        CGPathAddLineToPoint(pathToDraw, nil, self.width, self.height);
        return pathToDraw
    }
    
    func createPhysicalPath() -> CGPath {
        var pathToDraw : CGMutablePathRef = CGPathCreateMutable()
        // border
        CGPathMoveToPoint(pathToDraw, nil, marginX, marginY);
        CGPathAddLineToPoint(pathToDraw, nil, marginX, height-marginY);
        CGPathAddLineToPoint(pathToDraw, nil, width-marginX, height-marginY);
        CGPathAddLineToPoint(pathToDraw, nil, width-marginX, marginY);
        CGPathAddLineToPoint(pathToDraw, nil, marginX, marginY);
        return pathToDraw
    }
    
    func createPhysicsBody() -> SKPhysicsBody {
        let physicalPath :CGPath = self.createPhysicalPath()
        var body = SKPhysicsBody(edgeChainFromPath : physicalPath)
        body.dynamic = false
        
        return body
    }
    
    func setColor(color : UIColor) {
        self.strokeColor = color
    }
    
    
    
}