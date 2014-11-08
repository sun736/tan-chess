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
    private let restrictedAreaUp : SKShapeNode
    private let restrictedAreaDown : SKShapeNode
    private var colorTimer : NSTimer?
    private let timeInterval : NSTimeInterval = 1.4
    private let marginX : CGFloat = 0
    private let marginY : CGFloat
    private let restrictedAreaHeight : CGFloat
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(width : CGFloat, length : CGFloat, marginY : CGFloat){
        self.width = width
        self.length = length
        self.marginY = marginY
        self.restrictedAreaHeight = ceil((length - marginY * 2) / 4)
        self.backgroundUp = Board.createRect(width - marginX * 2, length: CGFloat(ceilf(Float(length/2 - marginY))) )
        self.backgroundDown = Board.createRect(width - marginX * 2, length : CGFloat(ceilf(Float(length/2 - marginY))) )
        self.restrictedAreaUp = Board.createRect(width - marginX * 2, length: restrictedAreaHeight)
        self.restrictedAreaDown = Board.createRect(width - marginX * 2, length: restrictedAreaHeight)
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
        self.backgroundDown.zPosition = -9.0
        self.addChild(self.backgroundDown)
        
        self.restrictedAreaDown.position = CGPoint(x : width / 2, y : CGFloat(ceilf(Float(restrictedAreaHeight / 2 + marginY))) )
        self.restrictedAreaDown.fillColor = UIColor.UIColorFromRGB(0x99FF99, alpha: 0.8)
        self.restrictedAreaDown.zPosition = 0
        self.addChild(self.restrictedAreaDown)
        self.restrictedAreaDown.alpha = 0
        
        self.restrictedAreaUp.position = CGPoint(x : width / 2, y : CGFloat(ceilf(Float(length - restrictedAreaHeight / 2 - marginY + 1))) )
        self.restrictedAreaUp.fillColor = UIColor.UIColorFromRGB(0x99FF99, alpha: 0.8)
        self.restrictedAreaUp.zPosition = 0
        self.addChild(self.restrictedAreaUp)
        self.restrictedAreaUp.alpha = 0
    }
    
    func setTurn(isUpTurn : Bool) {
        self.colorTimer?.invalidate()
        self.changeColor(isUpTurn)
        self.colorTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval,
            target: self,
            selector: Selector("startChangeColor:"),
            userInfo: isUpTurn,
            repeats: true)
    }
    
    func startChangeColor(timer: NSTimer) {
        if let isUpTurn = timer.userInfo as? Bool {
            self.changeColor(isUpTurn)
        }
    }
    
    func changeColor(isUpTurn : Bool) {
        let themeColor : UIColor = isUpTurn ? PLAYER2.themeColor : PLAYER1.themeColor
        let saturationBump: Float = 0.5
        var saturationUp : SKAction = SKAction.customActionWithDuration(timeInterval, {(node : SKNode!, time : CGFloat) -> Void in
            if let node = node as? SKShapeNode  {
                var changeScale : Float = Float(time / CGFloat(self.timeInterval / 2))
                changeScale = (saturationBump / 2.0) - (saturationBump / 2.0) * sin(Float(M_PI) * changeScale + Float(M_PI) / 2)
                node.fillColor = themeColor.colorWithSaturation(1.0 + CGFloat(changeScale))
            }})
        let node : SKShapeNode = isUpTurn ? self.backgroundUp : self.backgroundDown
        node.runAction(saturationUp)
    }
    
    func displayRestrictedArea(position : CGPoint, isUpTurn : Bool) {
        if isUpTurn && position.y < length / 2 {
            self.restrictedAreaDown.fadeTo(1, fadeOutFadeTime: 0.5)
        } else if !isUpTurn && position.y > length / 2 {
            self.restrictedAreaUp.fadeTo(1, fadeOutFadeTime: 0.5)
        }
    }
    
    func hideRestrictedArea(isUpTurn : Bool) {
        if isUpTurn {
            self.restrictedAreaDown.fadeTo(0, fadeOutFadeTime: 0.5)
        } else {
            self.restrictedAreaUp.fadeTo(0, fadeOutFadeTime: 0.5)
        }
    }
    
    func TurnDone() {
        self.colorTimer?.invalidate()
        self.restrictedAreaUp.fadeTo(0, fadeOutFadeTime: 0.5)
        self.restrictedAreaDown.fadeTo(0, fadeOutFadeTime: 0.5)
    }
    
    func isOut(position : CGPoint) -> Bool {
        if position.y < marginY || position.y > length - marginY {
            return true
        }
        return false
    }
    
    func isInRestrictedArea(position : CGPoint, isUpSide : Bool) -> Bool {
        if isUpSide {
            println(position.y)
            println(restrictedAreaHeight)
            return position.y < restrictedAreaHeight + marginY
        } else {
            println(position.y)
            println(length - restrictedAreaHeight)
            return position.y > length - restrictedAreaHeight - marginY
        }
    }
    
    class func BITMASK_BOARD() -> UInt32 {
        return 0x08
    }
    
}