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

let kDISTANCE_TO_FORCE:CGFloat = -100.0

class Piece: SKSpriteNode {

    var healthPoint : CGFloat
    var maxHealthPoint : CGFloat
    var radius : CGFloat
    var maxForce : CGFloat
    var player : Player
    var ring : Ring?
    var arrow: Arrow?
    var hpring: HPRing?
    // temporary solution to contact
    var isContacter: Bool

    let fadeOutWaitTime: NSTimeInterval = 0.1
    let fadeOutFadeTime: NSTimeInterval = 0.3
    
    init(texture: SKTexture, radius: CGFloat, healthPoint: CGFloat, maxHealthPoint: CGFloat, player : Player, mass: CGFloat, linearDamping: CGFloat, angularDamping: CGFloat, maxForce: CGFloat) {
        
        self.healthPoint = healthPoint
        self.maxHealthPoint = maxHealthPoint
        self.radius = radius
        self.maxForce = maxForce
        self.isContacter = false
        self.player = player
        super.init(texture: texture, color: nil,size: CGSizeMake(radius*2, radius*2))
        
        self.physicsBody = SKPhysicsBody(circleOfRadius:radius)
        self.physicsBody?.dynamic = true;
        self.physicsBody?.friction = 0.9
        self.physicsBody?.restitution = 0.5
        self.physicsBody?.linearDamping = linearDamping
        self.physicsBody?.angularDamping = angularDamping
        self.physicsBody?.mass = mass
        self.name = "piece"
        self.color = player.color
        
        setCollisionBitMask(player.bitMask)
        
        drawHPRing()
    }
    
    func setCollisionBitMask(collisionBitMask: UInt32) {
        self.physicsBody?.categoryBitMask = collisionBitMask
        self.physicsBody?.contactTestBitMask =  Piece.BITMASK_BLUE() | Piece.BITMASK_RED()
        self.physicsBody?.collisionBitMask =  Piece.BITMASK_BLUE() | Piece.BITMASK_RED()
        self.physicsBody?.usesPreciseCollisionDetection = true
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
        return (player.id == self.player.id)
    }
    
    // calculate a valid force based on piece's limit
    func forceForPullDistance(distance : CGVector) -> CGVector {
        var force = CGVectorMake(distance.dx * kDISTANCE_TO_FORCE, distance.dy * kDISTANCE_TO_FORCE)
        var forceLength = hypotf(Float(force.dx), Float(force.dy))
        if  forceLength > Float(maxForce) {
            let scaleFactor = maxForce / CGFloat(forceLength)
            force = CGVectorMake(force.dx * scaleFactor, force.dy * scaleFactor)
        }
        return force
    }
    
    // factory method
    class func newPiece(pieceType : PieceType, player : Player) -> Piece {
        switch pieceType {
        case .King:
            return PieceKing(player)
        case .Pawn:
            return PiecePawn(player)
        case .Elephant:
            return PieceElephant(player)
        }
    }
}

class PieceKing : Piece{
    
    let c_radius: CGFloat = 25
    let c_healthPoint: CGFloat = 50
    let c_maxhealthPoint: CGFloat = 50
    let c_mass : CGFloat = 10
    let c_linearDamping : CGFloat = 5
    let c_angularDamping: CGFloat = 7
    let c_maxForce = CGFloat.max
    let c_bluePic = "KingPiece_BLUE"
    let c_redPic = "KingPiece_RED"

    init(_ player : Player){

        let c_imageNamed = (player.bitMask == Piece.BITMASK_BLUE()) ? c_bluePic : c_redPic
        
        super.init(texture: SKTexture(imageNamed: c_imageNamed), radius: c_radius, healthPoint: c_healthPoint, maxHealthPoint : c_maxhealthPoint, player : player, mass: c_mass, linearDamping: c_linearDamping, angularDamping: c_angularDamping, maxForce : c_maxForce)

    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class PiecePawn : Piece{
    
    let c_radius: CGFloat = 20
    let c_healthPoint: CGFloat = 10
    let c_maxhealthPoint: CGFloat = 10
    let c_mass : CGFloat = 15
    let c_linearDamping : CGFloat = 10
    let c_angularDamping: CGFloat = 7
    let c_maxForce = CGFloat.max
    let c_bluePic = "PawnPiece_BLUE"
    let c_redPic = "PawnPiece_RED"

    init(_ player : Player){
        
        let c_imageNamed = (player.bitMask == Piece.BITMASK_BLUE()) ? c_bluePic : c_redPic
        
        super.init(texture: SKTexture(imageNamed: c_imageNamed), radius: c_radius, healthPoint: c_healthPoint, maxHealthPoint : c_maxhealthPoint, player : player, mass: c_mass, linearDamping: c_linearDamping, angularDamping: c_angularDamping, maxForce : c_maxForce)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class PieceElephant : Piece{
    
    let c_radius: CGFloat = 30
    let c_healthPoint: CGFloat = 10
    let c_maxhealthPoint: CGFloat = 10
    let c_mass : CGFloat = 3
    let c_linearDamping : CGFloat = 10
    let c_angularDamping: CGFloat = 7
    let c_maxForce = CGFloat.max
    let c_bluePic = "ElephantPiece_BLUE"
    let c_redPic = "ElephantPiece_RED"

    init(_ player : Player){
        
        let c_imageNamed = (player.bitMask == Piece.BITMASK_BLUE()) ? c_bluePic : c_redPic
        
        super.init(texture: SKTexture(imageNamed: c_imageNamed), radius: c_radius, healthPoint: c_healthPoint, maxHealthPoint : c_maxhealthPoint, player : player, mass: c_mass, linearDamping: c_linearDamping, angularDamping: c_angularDamping, maxForce : c_maxForce)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

