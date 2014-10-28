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
    private let marginX : CGFloat = 0
    private let marginY : CGFloat
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(width : CGFloat, length : CGFloat, marginY : CGFloat){
        self.width = width
        self.length = length
        self.marginY = marginY
        self.backgroundUp = Board.createRect(width - marginX * 2, length: CGFloat(ceilf(Float(length/2 - marginY))) )
        self.backgroundDown = Board.createRect(width - marginX * 2, length : CGFloat(ceilf(Float(length/2 - marginY))) )
        self.background = Board.createRect(width, length : length)
        super.init()
        self.configurePhysicsBody()
        self.configureBackground()
    }
    
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
        self.physicsBody?.categoryBitMask = Board.BITMASK_BOARD()
        self.physicsBody?.collisionBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_RED() | Piece.BITMASK_TRANS()
        self.physicsBody?.contactTestBitMask = 0x00
    }
    
    class func createRect(width : CGFloat, length : CGFloat) -> SKShapeNode {
        let size : CGSize = CGSizeMake(width, length)
        var rect = SKShapeNode(rectOfSize: size)
        rect.lineWidth = 0
        return rect
    }
    
    func configureBackground() {
        self.background.position = CGPoint(x : width / 2, y : length / 2)
        self.background.fillColor = UIColor.whiteColor()
        self.background.zPosition = -10.0
        self.addChild(self.background)
        
        self.backgroundUp.position = CGPoint(x : width / 2, y : CGFloat(ceilf(Float(length / 2 + (length - 2 * marginY) / 4))) )
        self.backgroundUp.fillColor = PLAYER2.themeColor
        self.backgroundUp.zPosition = -9.0
        self.addChild(self.backgroundUp)
        
        self.backgroundDown.position = CGPoint(x : width / 2, y : CGFloat(ceilf(Float(length / 2 -  (length - 2 * marginY) / 4))) )
        self.backgroundDown.fillColor = PLAYER1.themeColor
        self.backgroundUp.zPosition = -9.0
        self.addChild(self.backgroundDown)
    }
    
    func setColor(color : UIColor) {
//        self.strokeColor = color
    }
    
    func isOut(position : CGPoint) -> Bool {
        if position.y < marginY || position.y > length - marginY {
            return true
        }
        return false
    }
    
    class func BITMASK_BOARD() -> UInt32 {
        return 0x08
    }
    
}