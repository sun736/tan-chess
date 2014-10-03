//
//  Piece.swift
//  WildPiece
//
//  Created by Amelech on 9/26/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

class Piece: SKSpriteNode {

    var healthPoint : Int
    var maxHealthPoint : Int
    var radius : CGFloat
    var ring : SKShapeNode?
    var arrow: SKShapeNode?

    let fadeOutWaitTime: NSTimeInterval = 0.5
    let fadeOutFadeTime: NSTimeInterval = 0.7
    
    override init() {
        
        healthPoint = 30
        maxHealthPoint = 30
        radius = 0
        super.init(texture: SKTexture(imageNamed:""),color: nil,size: CGSizeMake(0, 0))
        physicsBody?.dynamic = true;
        physicsBody?.friction = 0.9
        
        physicsBody?.restitution = 0.5
        physicsBody?.linearDamping = 5
        physicsBody?.angularDamping = 7
        physicsBody?.mass = 5
        
    }
    
    func setCollisionBitMask(collisionBitMask: UInt32) {
        physicsBody?.categoryBitMask = collisionBitMask
        physicsBody?.contactTestBitMask = collisionBitMask
        physicsBody?.collisionBitMask = collisionBitMask
    }
    
    func getRadius() -> CGFloat{
        return radius
    }
    
    func BITMASK_BLUE() -> UInt32{
        return 0x01
    }
    
    func BITMASK_RED() -> UInt32{
        return 0x02
    }
    
    func deduceHealth() {
        self.healthPoint = self.healthPoint - 10
        if(self.healthPoint <= self.maxHealthPoint*6/10)
        {
            self.texture = SKTexture(imageNamed:"KingCoin_Broken")
        }
    }
    
    func fadeOut() {
        let waitAction = SKAction.waitForDuration(fadeOutWaitTime);
        let fadeAction = SKAction.fadeOutWithDuration(fadeOutFadeTime)
        let removeAction = SKAction.removeFromParent()
        let sequence = [waitAction, fadeAction, removeAction]
        self.runAction(SKAction.sequence(sequence))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func removeRing() {
        self.ring?.removeFromParent()
    }
    
    func drawRing() {
        self.removeRing()
        self.ring = Ring(CGPointMake(0, 0), getRadius())
        if let ring = self.ring {
            self.addChild(ring)
        }
    }
    
    func drawArrow(cgVector: CGVector) {
        self.removeArrow()
        var endPoition = CGPointMake(cgVector.dx/100, cgVector.dy/100)
        let arrowNode :SKShapeNode = Arrow(startPoint: CGPointMake(0, 0), endPoint: endPoition, tailWidth: 4, headWidth: 8, headLength: 6)
        self.arrow = arrowNode
        self.addChild(arrowNode)
    }
    
    func removeArrow() {
        self.arrow?.removeFromParent()
    }
}

class PieceKing : Piece{
    

    init(collisionBitMask : UInt32){

        super.init()
        radius = 50
        healthPoint = 50
        maxHealthPoint = 50
        if(collisionBitMask == BITMASK_BLUE())
        {
            texture = SKTexture(imageNamed:"KingCoin")
        }
        else if(collisionBitMask == BITMASK_RED())
        {
            texture = SKTexture(imageNamed:"KingCoin")
        }
        size = CGSizeMake(radius*2, radius*2)
        physicsBody = SKPhysicsBody(circleOfRadius:radius)
        physicsBody?.mass = 20;
        physicsBody?.linearDamping = 10
        physicsBody?.angularDamping = 7
        
        setCollisionBitMask(collisionBitMask)
        
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class PiecePawn : Piece{
    
    init(collisionBitMask : UInt32){
      
        super.init()
        radius = 35
        if(collisionBitMask == BITMASK_BLUE())
        {
            texture = SKTexture(imageNamed:"Coin")
        }
        else if(collisionBitMask == BITMASK_RED())
        {
            texture = SKTexture(imageNamed:"Coin")
        }
        size = CGSizeMake(radius*2, radius*2)
        physicsBody = SKPhysicsBody(circleOfRadius:radius)
        physicsBody?.mass = 2;
        physicsBody?.linearDamping = 10
        physicsBody?.angularDamping = 7
        
        setCollisionBitMask(collisionBitMask)

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

