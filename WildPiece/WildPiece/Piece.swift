//
//  Piece.swift
//  WildPiece
//
//  Created by Amelech on 9/26/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

enum PieceType : Printable {
    case King
    case Pawn
    case Elephant
    
    var description : String {
        switch self {
        case .King:
            return "King"
        case .Pawn:
            return "Pawn"
        case .Elephant:
            return "Elephant"
        default:
            return "default"
        }
    }
}

class Piece: SKSpriteNode {

    var healthPoint : Int
    var maxHealthPoint : Int
    var radius : CGFloat
    var ring : Ring?
    var arrow: Arrow?
    var hpring: HPRing?
    // temporary solution to contact
    var isContacter: Bool

    let fadeOutWaitTime: NSTimeInterval = 0.1
    let fadeOutFadeTime: NSTimeInterval = 0.3
    

    init(radius: CGFloat = 10, healthPoint: Int = 10, maxHealthPoint: Int = 10) {
        self.healthPoint = healthPoint
        self.maxHealthPoint = maxHealthPoint
        self.radius = radius
        self.isContacter = false
        super.init(texture: SKTexture(imageNamed:""),color: nil,size: CGSizeMake(0, 0))
        physicsBody?.dynamic = true;
        physicsBody?.friction = 0.9
        
        physicsBody?.restitution = 0.5
        physicsBody?.linearDamping = 5
        physicsBody?.angularDamping = 7
        physicsBody?.mass = 5
        name = "piece"
        drawHPRing()
    }
    
    func setCollisionBitMask(collisionBitMask: UInt32) {
        physicsBody?.categoryBitMask = collisionBitMask
        physicsBody?.contactTestBitMask =  Piece.BITMASK_BLUE() | Piece.BITMASK_RED()
        physicsBody?.collisionBitMask =  Piece.BITMASK_BLUE() | Piece.BITMASK_RED()
        physicsBody?.usesPreciseCollisionDetection = true
    }
    
    func getRadius() -> CGFloat{
        return radius
    }
    
    class func BITMASK_BLUE() -> UInt32{
        return 0x01
    }
    
    class func BITMASK_RED() -> UInt32{
        return 0x02
    }
    
    func deduceHealth() {
        self.healthPoint = self.healthPoint - 10
        if(self.healthPoint <= self.maxHealthPoint*6/10)
        {
           // self.texture = SKTexture(imageNamed:"KingCoin_Broken")
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
    
    
    func drawHPRing() {
        self.removeHPRing()
        self.hpring = HPRing(location: CGPointMake(0, 0), radius: getRadius(), hp: CGFloat(self.healthPoint), maxHp: CGFloat(self.maxHealthPoint))
        if let hpring = self.hpring {
            self.addChild(hpring)
        }
    }
    
    func removeHPRing() {
        self.hpring?.removeFromParent()
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
        var endPoition = CGPointMake(cgVector.dx/200 + self.position.x, cgVector.dy/200 + self.position.y)
        var outRadius = self.getRadius()
        if let ring = self.ring {
            outRadius = ring.getRadius()
        }
        let arrowNode :Arrow = Arrow(startPoint: self.position, endPoint: endPoition, tailWidth: 4, headWidth: 8, headLength: 6, parentRadius: outRadius)
        
        self.arrow = arrowNode
        self.parent?.addChild(arrowNode)
    }
    
    func removeArrow() {
        self.arrow?.removeFromParent()
    }
    
    func belongsTo(player : Player) -> Bool {
        if let body = self.physicsBody? {
            return (body.categoryBitMask == player.bitMask)
        }
        return false
    }
    
    // factory method
    class func newPiece(pieceType : PieceType, bitMask : UInt32) -> Piece {
        switch pieceType {
        case .King:
            return PieceKing(collisionBitMask: bitMask)
        case .Pawn:
            return PiecePawn(collisionBitMask: bitMask)
        case .Elephant:
            return PieceElephant(collisionBitMask: bitMask)
        default:
            println("default piece type: \(pieceType)")
            return Piece()
        }
    }
}

class PieceKing : Piece{
    

    init(collisionBitMask : UInt32){

        super.init(radius: 25, healthPoint: 50, maxHealthPoint: 50)

        if(collisionBitMask == Piece.BITMASK_BLUE())
        {
            texture = SKTexture(imageNamed:"KingPiece_BLUE")
        }
        else if(collisionBitMask == Piece.BITMASK_RED())
        {
            texture = SKTexture(imageNamed:"KingPiece_RED")
        }
        size = CGSizeMake(radius*2, radius*2)
        physicsBody = SKPhysicsBody(circleOfRadius:radius)
        physicsBody?.mass = 10;
        physicsBody?.linearDamping = 5
        physicsBody?.angularDamping = 7
        
        setCollisionBitMask(collisionBitMask)
        
    }
    
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class PiecePawn : Piece{
    
    init(collisionBitMask : UInt32){
      
        super.init(radius: 20)

        if(collisionBitMask == Piece.BITMASK_BLUE())
        {
            texture = SKTexture(imageNamed:"PawnPiece_BLUE")
        }
        else if(collisionBitMask == Piece.BITMASK_RED())
        {
            texture = SKTexture(imageNamed:"PawnPiece_RED")
        }
        size = CGSizeMake(radius*2, radius*2)
        physicsBody = SKPhysicsBody(circleOfRadius:radius)
        physicsBody?.mass = 15;
        physicsBody?.linearDamping = 10
        physicsBody?.angularDamping = 7
        
        setCollisionBitMask(collisionBitMask)

    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class PieceElephant : Piece{
    
    init(collisionBitMask : UInt32){
        
        super.init(radius: 30, healthPoint: 10, maxHealthPoint : 10)
        
        if(collisionBitMask == Piece.BITMASK_BLUE())
        {
            texture = SKTexture(imageNamed:"ElephantPiece_BLUE")
        }
        else if(collisionBitMask == Piece.BITMASK_RED())
        {
            texture = SKTexture(imageNamed:"ElephantPiece_RED")
        }
        size = CGSizeMake(radius*2, radius*2)
        physicsBody = SKPhysicsBody(circleOfRadius:radius)
        physicsBody?.mass = 3;
        physicsBody?.linearDamping = 10
        physicsBody?.angularDamping = 7
        setCollisionBitMask(collisionBitMask)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

