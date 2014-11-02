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
    case Rook
    case Canon
    case Knight
    
    var description : String {
        switch self {
        case .King:
            return "King"
        case .Pawn:
            return "Pawn"
        case .Elephant:
            return "Elephant"
        case .Rook:
            return "Rook"
        case .Canon:
            return "Canon"
        case .Knight:
            return "Knight"
        }
    }
}

let MAX_PULL_DISTANCE:CGFloat = 75
let FORCE_FACTOR : CGFloat = 2000.0

class Piece: SKSpriteNode {

    var healthPoint : CGFloat
    let maxHealthPoint : CGFloat
    let radius : CGFloat
    var maxForce : CGFloat {
        get {
            return maxForceLevel * FORCE_FACTOR
        }
    }
    var maxForceLevel : CGFloat
    let player : Player
    let pieceType : PieceType
    var distanceToForce : CGFloat {
        get {
            return -(maxForce / MAX_PULL_DISTANCE)
        }
    }
    var minForce : CGFloat {
        get {
            return radius * abs(distanceToForce)
        }
    }
    var ring : Ring?
    var arrow: Arrow?
    //var trajectory: Trajectory?
    var hpring: HPRing?
    var directionHint: DirectionHint?
    // temporary solution to contact
    var isContacter: Bool

    let fadeOutWaitTime: NSTimeInterval = 0.1
    let fadeOutFadeTime: NSTimeInterval = 0.3
    
    init(texture: SKTexture, radius: CGFloat, healthPoint: CGFloat, maxHealthPoint: CGFloat, player : Player, mass: CGFloat, linearDamping: CGFloat, angularDamping: CGFloat, maxForce: CGFloat, pieceType : PieceType) {
        
        self.isContacter = false
        self.player = player
        self.pieceType = pieceType
        self.healthPoint = healthPoint
        self.maxHealthPoint = maxHealthPoint
        self.radius = radius
        self.maxForceLevel = maxForce
        
        super.init(texture: texture, color: nil,size: CGSizeMake(radius*2, radius*2))
        
        self.physicsBody = SKPhysicsBody(circleOfRadius:radius)
        self.physicsBody?.dynamic = true;
        self.physicsBody?.friction = 0.9
        self.physicsBody?.restitution = 0.5
        self.physicsBody?.linearDamping = linearDamping
        self.physicsBody?.angularDamping = angularDamping
        self.physicsBody?.mass = mass
        self.physicsBody?.allowsRotation = false
        self.name = "piece"
        self.color = player.color
        
        self.updateParameter()
        
        setCollisionBitMask(player.bitMask)
        
        drawHPRing()
    }

    func updateParameter() {
        var rawDict = WPParameterSet.getParameterSet(forIdentifer: self.pieceType.description)
        if let dict = rawDict {
            self.maxForceLevel = CGFloat((dict.objectForKey("impulse") as? NSNumber)!.doubleValue)
            self.physicsBody?.mass = CGFloat((dict.objectForKey("mass") as? NSNumber)!.doubleValue)
            self.physicsBody?.linearDamping = CGFloat((dict.objectForKey("damping") as? NSNumber)!.doubleValue)
            self.physicsBody?.restitution = CGFloat((dict.objectForKey("restitution") as? NSNumber)!.doubleValue)
        }
    }
    
    func setCollisionBitMask(collisionBitMask: UInt32) {
        self.physicsBody?.categoryBitMask = collisionBitMask
        self.physicsBody?.contactTestBitMask =  Piece.BITMASK_BLUE() | Piece.BITMASK_RED() | Piece.BITMASK_TRANS()
        self.physicsBody?.collisionBitMask =  Piece.BITMASK_BLUE() | Piece.BITMASK_RED() | Board.BITMASK_BOARD()
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
    
    class func BITMASK_TRANS() -> UInt32 {
        return 0x04
    }
    
    func deduceHealth() {
        self.healthPoint = self.healthPoint - 10
        if(self.healthPoint <= self.maxHealthPoint*6/10)
        {
           // self.texture = SKTexture(imageNamed:"KingCoin_Broken")
        }
    }
    
    func deduceHealthToDeath() {
        self.healthPoint = self.healthPoint - self.healthPoint
    }
    
    func fadeOut() {
        let waitAction = SKAction.waitForDuration(fadeOutWaitTime);
        let fadeAction = SKAction.fadeOutWithDuration(fadeOutFadeTime)
        let removeAction = SKAction.removeFromParent()
        let sequence = [waitAction, fadeAction, removeAction]
        self.runAction(SKAction.sequence(sequence))
    }
    
    func fadeTo() {
        let fadeOutAct = SKAction.fadeAlphaTo(0.5, duration: fadeOutFadeTime)
        let sequence = [fadeOutAct];
        self.runAction(SKAction.sequence(sequence));
    }
    
    func cancelFade() {
        let fadeOutAct = SKAction.fadeAlphaTo(1.0, duration: fadeOutFadeTime)
        let sequence = [fadeOutAct];
        self.runAction(SKAction.sequence(sequence));
    }
    
    func flash() {
        let waitAction = SKAction.waitForDuration(fadeOutWaitTime);
        let fadeOutAct = SKAction.fadeAlphaTo(0.4, duration: fadeOutFadeTime);
        let fadeInAct = SKAction.fadeInWithDuration(fadeOutFadeTime);
        let sequence = [fadeOutAct, fadeInAct];
        self.runAction(SKAction.sequence(sequence));
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawDirectionHint() {
        self.removeDirectionHint()
        self.directionHint = DirectionHint(location: self.position, lineColor: self.color, piece: self)
        if let directionHint = self.directionHint {
            self.parent?.addChild(directionHint)
        }
    }
    
    func removeDirectionHint() {
        self.directionHint?.removeFromParent()
    }
    
    func drawHPRing() {
        if(self.pieceType == PieceType.King) {
            self.removeHPRing()
            self.hpring = HPRing(location: CGPointMake(0, 0), radius: getRadius(), hp: CGFloat(self.healthPoint), maxHp: CGFloat(self.maxHealthPoint),  color: self.color)
            if let hpring = self.hpring {
                self.addChild(hpring)
            }
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
    
    func drawArrow(force: CGVector) {
        self.removeArrow()
        var endPoition = CGPointMake(force.dx/200 + self.position.x, force.dy/200 + self.position.y)
        var outRadius = self.getRadius()
        if let ring = self.ring {
            outRadius = ring.getRadius()
        }

        let arrowNode :Arrow = Arrow(startPoint: self.position, endPoint: endPoition, parentRadius: outRadius, forcePercentage: forcePercentage(force))
        
        self.arrow = arrowNode
        self.parent?.addChild(arrowNode)
    }
    
    func removeArrow() {
        self.arrow?.removeFromParent()
    }
    
    /*func drawTrajectory(force: CGVector){
        self.removeTrajectory()
        var endPosition = CGPointMake(force.dx/50 + self.position.x, force.dy/50 + self.position.y)
        let trajectoryNode :Trajectory = Trajectory(startPoint: self.position, endPoint: endPosition, piece: self, player: self.player)
        self.trajectory = trajectoryNode
        self.parent?.addChild(trajectoryNode)
        
    }
    
    func removeTrajectory(){
        self.trajectory?.removeFromParent()
    }*/
    
    // calculate a valid force based on piece's limit
    func forceForPullDistance(distance : CGVector) -> CGVector {
        var force = CGVectorMake(distance.dx * distanceToForce, distance.dy * distanceToForce)
        var forceLength = hypotf(Float(force.dx), Float(force.dy))
        if  forceLength > Float(maxForce) {
            let scaleFactor = maxForce / CGFloat(forceLength)
            force = CGVectorMake(force.dx * scaleFactor, force.dy * scaleFactor)
        }
        return force
    }
    
    func forcePercentage(force : CGVector) -> CGFloat {
        var forceLength = hypotf(Float(force.dx), Float(force.dy))
        var percentage = (CGFloat(forceLength) - minForce) / (maxForce - minForce)
        return percentage >= 0 ? percentage : 0
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
        case .Rook:
            return PieceRock(player)
        case .Knight:
            return PieceKnight(player)
        case .Canon:
            return PieceCanon(player)
        }
    }
}

