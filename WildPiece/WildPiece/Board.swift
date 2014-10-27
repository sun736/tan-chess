//
//  Board.swift
//  WildPiece
//
//  Created by Kaiqi on 14/10/25.
//  Copyright (c) 2014年 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

class Board : SKNode {

    private let width : CGFloat
    private let length : CGFloat
    private let background : SKShapeNode
    private let backgroundUp : SKShapeNode
    private let backgroundDown : SKShapeNode
    private let marginX : CGFloat
    private let marginY : CGFloat
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(width : CGFloat, length : CGFloat, marginX : CGFloat, marginY : CGFloat){
        self.width = width
        self.length = length
        self.marginX = marginX
        self.marginY = marginY
        self.backgroundUp = Board.createRect(width - marginX * 2, length: length/2 - marginY)
        self.backgroundDown = Board.createRect(width - marginX * 2, length : length/2 - marginY)
        self.background = Board.createRect(width, length : length)
        super.init()
//        self.configureVisibleBorder()
        self.configurePhysicsBody()
        self.configureBackground()
    }
    
//    func configureVisibleBorder() {
//        self.strokeColor = UIColor.whiteColor()
//        self.lineWidth = 2
//        
//        var path : CGMutablePathRef = CGPathCreateMutable()
//        // border
//        CGPathMoveToPoint(path, nil, marginX, marginY)
//        CGPathAddLineToPoint(path, nil, marginX, length-marginY)
//        CGPathAddLineToPoint(path, nil, width-marginX, length-marginY)
//        CGPathAddLineToPoint(path, nil, width-marginX, marginY)
//        CGPathAddLineToPoint(path, nil, marginX, marginY)
//
//        // center line
//        CGPathMoveToPoint(path, nil, 0, length / 2)
//        CGPathAddLineToPoint(path, nil, width, length / 2)
//        
//        self.path = path
//    }
    
    func createBorderPath( x : CGFloat) -> CGPath {
        var path : CGMutablePathRef = CGPathCreateMutable()
        // one side border
        CGPathMoveToPoint(path, nil, x, marginY)
        CGPathAddLineToPoint(path, nil, x, length-marginY)
        
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
    
    class func createRect(width : CGFloat, length : CGFloat) -> SKShapeNode {
        let size : CGSize = CGSizeMake(width, length)
        var rect = SKShapeNode(rectOfSize: size)
        return rect
    }
    
    func configureBackground(){
        self.background.position = CGPoint(x : width / 2, y : length / 2)
        self.background.fillColor = UIColor.whiteColor()
        self.background.zPosition = -10.0
        self.addChild(self.background)
        
        self.backgroundUp.position = CGPoint(x : width / 2, y : length / 2 + (length - 2 * marginY) / 4 )
        self.backgroundUp.fillColor = PLAYER2.themeColor
        self.backgroundUp.zPosition = -9.0
        self.addChild(self.backgroundUp)
        
        self.backgroundDown.position = CGPoint(x : width / 2, y : length / 2 -  (length - 2 * marginY) / 4)
        self.backgroundDown.fillColor = PLAYER1.themeColor
        self.backgroundUp.zPosition = -9.0
        self.addChild(self.backgroundDown)
    }
    
    func setColor(color : UIColor) {
//        self.strokeColor = color
    }
    
    
    
}