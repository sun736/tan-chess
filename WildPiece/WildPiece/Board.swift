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
        
        var path : CGMutablePathRef = CGPathCreateMutable()
        // border
        CGPathMoveToPoint(path, nil, marginX, marginY)
        CGPathAddLineToPoint(path, nil, marginX, height-marginY)
        CGPathAddLineToPoint(path, nil, width-marginX, height-marginY)
        CGPathAddLineToPoint(path, nil, width-marginX, marginY)
        CGPathAddLineToPoint(path, nil, marginX, marginY)

        // center line
        CGPathMoveToPoint(path, nil, 0, height / 2)
        CGPathAddLineToPoint(path, nil, width, height / 2)
        
        self.path = path
    }
    
    func createBorderPath( x : CGFloat) -> CGPath {
        var path : CGMutablePathRef = CGPathCreateMutable()
        // one side border
        CGPathMoveToPoint(path, nil, x, marginY)
        CGPathAddLineToPoint(path, nil, x, height-marginY)
        
        return path
    }
    
    func configurePhysicsBody() {
        let borderLeft :CGPath = self.createBorderPath(marginX)
        let borderRight :CGPath = self.createBorderPath(width-marginX)
        var bodyLeft = SKPhysicsBody(edgeChainFromPath : borderLeft)
        var bodyRight = SKPhysicsBody(edgeChainFromPath : borderRight)
        
        var body = SKPhysicsBody(bodies : [bodyLeft, bodyRight])
        body.dynamic = false
        self.physicsBody = body
    }
    
    func configureBackground(){
        if let background = self.background {
            let backgroundNode = SKSpriteNode(imageNamed: background)
            println(self.frame)
            backgroundNode.position = CGPoint(x : width / 2, y : height / 2)
            backgroundNode.zPosition = -5.0
            self.addChild(backgroundNode)
        }
    }
    
    func setColor(color : UIColor) {
        self.strokeColor = color
    }
    
    
    
}