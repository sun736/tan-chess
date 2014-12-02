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
    private let segment : SKSpriteNode
    private var indicator : SKSpriteNode
    //add a skill cool down bar
    private var blueSkillBar : SKSpriteNode
    private var redSkillBar : SKSpriteNode
    private var scaleArray = [250, 2, 1.5]
    var skillController : SkillController
    
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
        self.blueSkillBar = SKSpriteNode(imageNamed: "skillBarBlue")
        self.redSkillBar = SKSpriteNode(imageNamed: "skillBarRed")
        self.skillController = SkillController()
        self.segment = SKSpriteNode(imageNamed:"segment")
        self.indicator = SKSpriteNode(imageNamed:"BlueIndicator")
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
        body.restitution = 1.0
        self.physicsBody = body
        self.physicsBody?.categoryBitMask = Board.BITMASK_BOARD()
        self.physicsBody?.collisionBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_RED() | Piece.BITMASK_TRANS()
        self.physicsBody?.contactTestBitMask = 0x00
    }
    
    func createPhysicBody(width : CGFloat) -> SKPhysicsBody
    {
        var body = SKPhysicsBody(rectangleOfSize: CGSizeMake(width, 5))
        body.dynamic = false
        body.categoryBitMask = Board.BITMASK_BOARD()
        body.collisionBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_RED() | Piece.BITMASK_TRANS()
        body.contactTestBitMask = 0x00
        return body
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
        self.restrictedAreaDown.zPosition = -8.0
        self.addChild(self.restrictedAreaDown)
        self.restrictedAreaDown.alpha = 0
        
        self.restrictedAreaUp.position = CGPoint(x : width / 2, y : CGFloat(ceilf(Float(length - restrictedAreaHeight / 2 - marginY + 1))) )
        self.restrictedAreaUp.fillColor = UIColor.UIColorFromRGB(0x99FF99, alpha: 0.8)
        self.restrictedAreaUp.zPosition = -8.0
        self.addChild(self.restrictedAreaUp)
        self.restrictedAreaUp.alpha = 0
        
        self.blueSkillBar.position = CGPointMake(-1, marginY-2.5)
        self.blueSkillBar.size = CGSizeMake(1, 5)
        self.blueSkillBar.physicsBody = createPhysicBody(1)
        self.addChild(self.blueSkillBar)
        //self.increaseSkill(0)
        self.redSkillBar.position = CGPointMake(376, length - marginY+2.5);
        self.redSkillBar.size = CGSizeMake(1, 5);
        self.redSkillBar.physicsBody = createPhysicBody(1)
        self.redSkillBar.zRotation = CGFloat(M_PI)
        self.addChild(self.redSkillBar)
        
        self.segment.position = CGPoint(x:width/2, y:length/2)
        self.addChild(self.segment)
        
        self.indicator.size = CGSizeMake(60,60)
        self.indicator.position = CGPoint(x:width/2, y:length/2)
        self.addChild(self.indicator)
    }
    
    func flipTurn(isUpTurn: Bool)
    {
        if isUpTurn
        {
            self.indicator.runAction(SKAction.fadeAlphaTo(0.1,duration:0.3), completion: { self.indicator.texture = SKTexture(imageNamed:"RedIndicator")
                self.indicator.runAction(SKAction.fadeAlphaTo(1.0,duration:0.3))}
            )
        }else
        {
            self.indicator.runAction(SKAction.fadeAlphaTo(0.1,duration:0.3), completion: { self.indicator.texture = SKTexture(imageNamed:"BlueIndicator")
                self.indicator.runAction(SKAction.fadeAlphaTo(1.0,duration:0.3))}
            )
        }
        
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
    
    func isInRestrictedArea(piece : Piece) -> Bool {
        var isUpSide = piece.player.isUpSide
        if isUpSide {
            return piece.position.y < restrictedAreaHeight + marginY
        } else {
            return piece.position.y > length - restrictedAreaHeight - marginY
        }
    }
    
    class func BITMASK_BOARD() -> UInt32 {
        return 0x20
    }
    
    func increaseSkill( player: Player ){
        if player.id == 1{
            var index = self.skillController.increaseBlueCD()
            var newLength  = (Int)(self.length/3)
            newLength = (newLength+35) * (index+1)
            self.blueSkillBar.runAction(SKAction.resizeToWidth(CGFloat(newLength), duration: 0.3))
            self.blueSkillBar.physicsBody = createPhysicBody(CGFloat(newLength))
        }
        else
        {
            var index = self.skillController.increaseRedCD()
            var newLength  = (Int)(self.length/3)
            newLength = (newLength+35) * (index+1)
            self.redSkillBar.runAction(SKAction.resizeToWidth(CGFloat(newLength), duration: 0.3))
            self.redSkillBar.physicsBody = createPhysicBody(CGFloat(newLength))
        }
        
    }
    
    func setSkillBar(player: Player, cd: Int)
    {
        self.skillController.setCD(player, cd: cd)
        var newLength  = (Int)(self.length/3)
        newLength = (newLength+35) * (cd+1)
        if player.id == 1
        {
            self.blueSkillBar.runAction(SKAction.resizeToWidth(CGFloat(newLength), duration: 0.3))
            self.blueSkillBar.physicsBody = createPhysicBody(CGFloat(newLength))
        }else
        {
            self.redSkillBar.runAction(SKAction.resizeToWidth(CGFloat(newLength), duration: 0.3))
            self.redSkillBar.physicsBody = createPhysicBody(CGFloat(newLength))
        }
    }
    
    func cleanSkillBar()
    {
        self.blueSkillBar.runAction(SKAction.resizeToWidth(CGFloat(1), duration: 0.3))
        self.blueSkillBar.physicsBody = createPhysicBody(CGFloat(1))
        self.skillController.clearBlueCD()
        self.redSkillBar.runAction(SKAction.resizeToWidth(CGFloat(1), duration: 0.3))
        self.redSkillBar.physicsBody = createPhysicBody(CGFloat(1))
        self.skillController.clearRedCD()
    }
    
    func resetSkillBar( player: Player)
    {
        if player.id == 1
        {
            self.blueSkillBar.runAction(SKAction.resizeToWidth(CGFloat(1), duration: 0.3))
            self.blueSkillBar.physicsBody = createPhysicBody(CGFloat(1))
            self.skillController.clearBlueCD()
        }else
        {
            self.redSkillBar.runAction(SKAction.resizeToWidth(CGFloat(1), duration: 0.3))
            self.redSkillBar.physicsBody = createPhysicBody(CGFloat(1))
            self.skillController.clearRedCD()
        }
    }
    
}