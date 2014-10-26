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
    let background : String?
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(width : CGFloat, height : CGFloat, background : String?){
        self.width = width
        self.height = height
        self.background = background
        super.init()
        self.configureVisibleBorder()
        self.configurePhysicsBody()
        self.configureBackground()
    }
    
    func configureVisibleBorder() {
        self.strokeColor = UIColor.whiteColor()
        self.lineWidth = 2
        
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
        
        self.path = pathToDraw
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
    
    func configurePhysicsBody() {
        let physicalPath :CGPath = self.createPhysicalPath()
        var body = SKPhysicsBody(edgeChainFromPath : physicalPath)
        body.dynamic = false
        body.categoryBitMask = 0x04
        body.collisionBitMask = 0x04
        
        self.physicsBody = body
    }
    
    func configureBackground(){
        if let background = self.background {
            let backgroundNode = SKSpriteNode(imageNamed: background)
            backgroundNode.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
            backgroundNode.zPosition = -10.0
            self.addChild(backgroundNode)
        }
    }
    
    func setColor(color : UIColor) {
        self.strokeColor = color
    }
    
    
    
}