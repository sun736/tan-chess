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
    case General
    
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
        case .General:
            return "General"
        }
    }
}

let MAX_PULL_DISTANCE:CGFloat = 85.0
let FORCE_FACTOR : CGFloat = 2000.0

typealias PieceTouchRegion = TouchableRegion

class Piece: SKSpriteNode, Touchable {

    
    let kExplosionForce : CGFloat = 500.0
    var healthPoint : CGFloat
    let maxHealthPoint : CGFloat
    let radius : CGFloat
    var maxForce : CGFloat {
        return maxForceLevel * FORCE_FACTOR
    }
    var maxForceLevel : CGFloat
    let player : Player
    let pieceType : PieceType
    var distanceToForce : CGFloat {
        return -(maxForce / MAX_PULL_DISTANCE)
    }
    var minForce : CGFloat {
        // println("regionRadius: \(touchRegion.regionRadius)")
        return touchRegion.regionRadius * abs(distanceToForce)
    }
    var ring : Ring? = nil
    var arrow: Arrow? = nil
    var trajectory: SKShapeNode? = nil
    var hpring: HPRing? = nil
    var directionHint: DirectionHint? = nil
    var shield: SKSpriteNode? = nil
    var powerRing : SKSpriteNode? = nil
    var indicatorRing : SKSpriteNode? = nil
    var isPowered : Bool
    var shouldDrawTrajectory : Bool
    
//    var aimNode : SKSpriteNode? = nil;
//    var forceNode : SKSpriteNode? = nil;
//    var shieldNode: SKSpriteNode? = nil;

    var isContacter: Bool

    let fadeOutWaitTime: NSTimeInterval = 0.01
    let fadeOutFadeTime: NSTimeInterval = 0.3
    
    init(texture: SKTexture, radius: CGFloat, healthPoint: CGFloat, maxHealthPoint: CGFloat, player : Player, mass: CGFloat, linearDamping: CGFloat, angularDamping: CGFloat, maxForce: CGFloat, pieceType : PieceType) {
        
        self.isContacter = false
        self.isPowered = false
        self.shouldDrawTrajectory = false
        self.player = player
        self.pieceType = pieceType
        self.healthPoint = healthPoint
        self.maxHealthPoint = maxHealthPoint
        self.radius = radius
        self.maxForceLevel = maxForce
        self.touchRegion = PieceTouchRegion(radius)
        
        super.init(texture: texture, color: nil,size: CGSizeMake(radius*2, radius*2))
        
        self.physicsBody = SKPhysicsBody(circleOfRadius:radius)
        self.physicsBody?.dynamic = true;
        self.physicsBody?.friction = 0.9
        self.physicsBody?.restitution = 0.5
        self.physicsBody?.linearDamping = linearDamping
        self.physicsBody?.angularDamping = angularDamping
        self.physicsBody?.mass = mass
        self.physicsBody?.allowsRotation = false
        self.color = player.color
        
        self.updateParameter()
        
        setCollisionBitMask(player.bitMask)
        
        drawHPRing()
        configureTouchRegion()
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
        self.physicsBody?.collisionBitMask =  Piece.BITMASK_BLUE() | Piece.BITMASK_RED() | Board.BITMASK_BOARD() | Piece.BITMASK_EXPLOSION() | Piece.BITMASK_BULLET()
        self.physicsBody?.usesPreciseCollisionDetection = true
    }
    
    func explode(scene: GameScene) {
        
        self.showExplosionAnimation()
        
        self.runAction(SKAction.fadeAlphaTo(0, duration: 0.7))
        
        self.physicsBody?.dynamic = false

        dispatch_after(dispatch_time_t(0.3), dispatch_get_main_queue()) { () -> Void in
            var forces: [CGVector] = []
            let forceVal1 = self.kExplosionForce
            let forceVal2 = self.kExplosionForce/sqrt(2.0)
            forces.append(CGVectorMake(forceVal1, 0))
            forces.append(CGVectorMake(forceVal2, forceVal2))
            forces.append(CGVectorMake(0, forceVal1))
            forces.append(CGVectorMake(-forceVal2, forceVal2))
            forces.append(CGVectorMake(-forceVal1, 0))
            forces.append(CGVectorMake(-forceVal2, -forceVal2))
            forces.append(CGVectorMake(0, -forceVal1))
            forces.append(CGVectorMake(forceVal2, -forceVal2))
            
            self.physicsBody?.categoryBitMask = Piece.BITMASK_BULLET()
            for force in forces {
                let node = SKShapeNode(circleOfRadius: self.radius)
                var body = SKPhysicsBody(circleOfRadius: self.radius)
                node.lineWidth = 0
//                node.fillColor = self.color
                node.position = self.position
                node.physicsBody = body
                node.physicsBody?.dynamic = true
                node.physicsBody?.linearDamping = 0.5
                node.physicsBody?.mass = self.physicsBody!.mass
                node.physicsBody?.allowsRotation = false
                node.physicsBody?.categoryBitMask = Piece.BITMASK_BULLET()
                node.physicsBody?.collisionBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_RED()
                node.physicsBody?.contactTestBitMask = 0x00
                self.parent?.addChild(node)
                println(force.dy)
                let waitAction = SKAction.waitForDuration(1.0)
                let removeAction = SKAction.removeFromParent()
                self.runAction(waitAction)
                let fadeAction = SKAction.fadeOutWithDuration(1.0)
                let sequence = SKAction.sequence([fadeAction, removeAction])
                node.runAction(sequence)
                scene.applyImpulseToWorldObject(node, force : force)
            }
            self.die(triggerAction: true)
        }
    }
    
    func showExplosionAnimation() {
        var emitterNode = SKEmitterNode()
        emitterNode.particleTexture = SKTexture(imageNamed: "shatter")
        emitterNode.particleColor = self.player.color
        emitterNode.particleColorBlendFactor = 1.0
        emitterNode.particleBlendMode = SKBlendMode.Alpha
        emitterNode.particleScale = 0.1
        emitterNode.particleScaleRange = 0.3
        emitterNode.particleScaleSpeed = 0.3
        emitterNode.particleLifetime = 1
        emitterNode.particleBirthRate = 500
        emitterNode.particleRotation = 0
        emitterNode.particleRotationRange = 360
        emitterNode.emissionAngleRange = 360
        emitterNode.particleAlpha = 1
        emitterNode.particleAlphaSpeed = -1
        emitterNode.numParticlesToEmit = 150
        emitterNode.particleSpeed = 100
        emitterNode.position = self.position
        self.scene?.addChild(emitterNode)
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
    
    class func BITMASK_EXPLOSION() -> UInt32 {
        return 0x08
    }
    
    class func BITMASK_BULLET() -> UInt32 {
        return 0x10
    }
    
    func deduceHealth() {
        if self.shield == nil {
            self.healthPoint = self.healthPoint - 10
        } else {
            removeCircle()
        }
    }

    func deduceHealthToDeath() {
        if self.shield == nil {
            self.healthPoint = self.healthPoint - self.healthPoint
        } else {
            removeCircle()
        }
    }
    
    private func fadeOut() {
        self.fadeOut(fadeOutWaitTime, fadeOutFadeTime: fadeOutFadeTime)
    }
    
    func fadeTo() {
        self.fadeTo(0.4, fadeOutFadeTime: fadeOutFadeTime)
    }
    
    func cancelFade() {
        self.cancelFade(fadeOutFadeTime)
    }
    
    func flash() {
        self.flash(fadeOutWaitTime, fadeOutFadeTime: fadeOutFadeTime)
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
        self.directionHint = nil
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
        self.hpring = nil
    }
    
    func removeRing() {
        self.ring?.removeFromParent()
        self.ring = nil
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
        self.arrow = nil
    }
    
    func drawTouchIndicator() {
        if indicatorRing == nil {
            var ring = SKSpriteNode(imageNamed: player == PLAYER1 ? "BlueRing" : "RedRing")
            ring.zPosition = -1
            ring.size = self.size
            addChild(ring)
            indicatorRing = ring
        }
        if indicatorRing?.actionForKey("draw") != nil {
            return
        }
        indicatorRing?.removeAllActions()
        let expendAction = SKAction.resizeToWidth(2 * touchRadius, height: 2 * touchRadius, duration: 0.1)
        indicatorRing?.runAction(expendAction, withKey: "draw")
    }
    
    func removeTouchIndicator(animated: Bool)
    {
        if indicatorRing == nil {
            return
        }
        if animated {
            if indicatorRing?.actionForKey("remove") != nil {
                return
            }
            let resizeAction = SKAction.resizeToWidth(2 * radius, height: 2 * radius, duration: 0.16)
            let completionAction = SKAction.runBlock({
                self.indicatorRing?.removeFromParent()
                self.indicatorRing = nil
            })
            let sequence = SKAction.sequence([resizeAction, completionAction])
            indicatorRing?.removeAllActions()
            indicatorRing?.runAction(sequence, withKey: "remove")
        } else {
            self.indicatorRing?.removeFromParent()
            self.indicatorRing = nil
        }
    }
    
    func drawCircle(flag : Bool) {
        self.removeCircle()
//        self.shield = Shield(CGPointMake(0, 0), getRadius())
//        if let shield = self.shield {
//            self.addChild(shield)
//        }
        self.shield = SKSpriteNode(imageNamed:"shield")
        if !flag
        {
            self.shield?.texture = SKTexture(imageNamed: "bomb")
        }
        self.shield?.size = CGSizeMake(CGFloat(50),CGFloat(50))
        self.addChild(self.shield!)
        
        var rotateAction = SKAction.rotateByAngle(CGFloat(1),duration: 0.3)
        self.shield?.runAction(SKAction.repeatActionForever(rotateAction))
    }
    
    func removeCircle() {
        var fadeoutAction = SKAction.fadeAlphaTo(0.0, duration: 0.3)
        self.shield?.runAction(fadeoutAction,completion:{
            self.shield?.removeFromParent()
            self.shield = nil
        })
    }
    
    func drawPowerRing()
    {
        self.powerRing = SKSpriteNode(imageNamed: "BlueRing")

        if self.player.id == 2
        {
            self.powerRing?.texture = SKTexture(imageNamed: "RedRing")
        }
        
        powerRing?.zPosition = -1
        powerRing?.size = self.size
        self.addChild(powerRing!)
        var resizeAction = SKAction.resizeToWidth(70, height: 70, duration: 1.2)
        var origionalSize = SKAction.resizeToWidth(40 , height: 40, duration: 0.0)
        var fadeAction = SKAction.fadeAlphaTo(0.0, duration: 1.2)
        var fadeInAction = SKAction.fadeAlphaTo(1.0, duration: 0.0)
        var group1 = SKAction.group([resizeAction,fadeAction])
        var group2 = SKAction.group([origionalSize,fadeInAction])
        var sequence = SKAction.sequence([group1, group2])
        powerRing?.runAction(SKAction.repeatActionForever(sequence))
    }
    
    func removePowerRing()
    {
        self.powerRing?.removeFromParent()
    }
    
    func drawExplode()
    {
        self.powerRing = SKSpriteNode(imageNamed: "RedRing")
        self.powerRing?.size = self.size
        self.powerRing?.alpha = 0.7
        self.addChild(self.powerRing!)
        var fadeOutAction = SKAction.fadeAlphaTo(0.0, duration: 0.7)
        var fadeInAction = SKAction.fadeAlphaTo(0.7, duration: 0.7)
        var sequence = SKAction.sequence([fadeOutAction, fadeInAction])
        self.powerRing?.runAction(SKAction.repeatActionForever(sequence))
    }
    
    func drawIndicator()
    {
        self.powerRing = SKSpriteNode(imageNamed: "BlueRing")
        
        if self.player.id == 2
        {
            self.powerRing?.texture = SKTexture(imageNamed: "RedRing")
        }
        
        powerRing?.zPosition = -1
        powerRing?.size = self.size
        self.addChild(powerRing!)
        var resizeAction = SKAction.resizeToWidth(70, height: 70, duration: 0.6)
        var fadeAction = SKAction.fadeAlphaTo(0.0, duration: 0.6)
        var group1 = SKAction.group([resizeAction,fadeAction])
        powerRing?.runAction(group1)
        
    }
    
    func drawTrajectory(){
        
        if self.shouldDrawTrajectory == false
        {
            return
        }
        
        self.removeTrajectory()
        let node = SKShapeNode(circleOfRadius: 20.0)
        node.alpha = 0.7
        node.fillColor = self.color
        node.lineWidth = 0
        node.position = self.position
        node.physicsBody = SKPhysicsBody(circleOfRadius:8.0)
        node.physicsBody?.dynamic = true
        node.physicsBody?.friction = self.physicsBody!.friction
        node.physicsBody?.restitution = self.physicsBody!.restitution
        node.physicsBody?.linearDamping = self.physicsBody!.linearDamping
        node.physicsBody?.angularDamping = self.physicsBody!.angularDamping
        node.physicsBody?.mass = self.physicsBody!.mass
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.categoryBitMask = 0x00
        node.physicsBody?.collisionBitMask = 0x00
        node.physicsBody?.contactTestBitMask = 0x00
        
        self.trajectory = node
        self.parent?.addChild(node)
        let waitAction = SKAction.waitForDuration(3.0)
        self.runAction(waitAction)
        let fadeAction = SKAction.fadeOutWithDuration(1.0)
        node.runAction(fadeAction)
    }
    
    func removeTrajectory(){
        self.trajectory?.removeFromParent()
        self.trajectory = nil
    }
    
    // calculate a valid force based on piece's limit
    func forceForPullDistance(distance : CGVector) -> CGVector {
        if self.isPowered == true{
            var force = CGVectorMake(distance.dx * distanceToForce * 2, distance.dy * distanceToForce * 2)
            var forceLength = hypotf(Float(force.dx), Float(force.dy))
            if  forceLength > Float(maxForce * 2) {
                let scaleFactor = maxForce * 2 / CGFloat(forceLength)
                force = CGVectorMake(force.dx * scaleFactor, force.dy * scaleFactor)
            }

            return force
        }else{
            var force = CGVectorMake(distance.dx * distanceToForce, distance.dy * distanceToForce)
            var forceLength = hypotf(Float(force.dx), Float(force.dy))
            if  forceLength > Float(maxForce) {
                let scaleFactor = maxForce / CGFloat(forceLength)
                force = CGVectorMake(force.dx * scaleFactor, force.dy * scaleFactor)
            }
            return force
        }
    }
    
    func forcePercentage(force : CGVector) -> CGFloat {
        var forceLength = hypotf(Float(force.dx), Float(force.dy))
        var percentage = (CGFloat(forceLength) - minForce) / (maxForce - minForce)
        return percentage >= 0 ? percentage : 0
    }
    
    func removeSkill()
    {
        self.isPowered = false
    }
    
//    //MARK: Show & Hide skill
//    func showSkill()
//    {
//        var size = CGSizeMake(40.0, 40.0)
//        let rotation = M_PI_4
//        var indicator = 0
//        if self.player.id == 1
//        {
//            indicator = 1
//        }else
//        {
//            indicator = -1
//        }
//
//        if indicator == 1
//        {
//            self.aimNode = SKSpriteNode(imageNamed: "Aim_BLUE")
//        }
//        else
//        {
//            self.aimNode = SKSpriteNode(imageNamed: "Aim_RED")
//        }
//        
//        self.aimNode?.name = "Aim"
//        self.aimNode?.position = CGPointZero
//        self.aimNode?.size = size
//        self.aimNode?.zRotation = CGFloat(rotation)
//        self.addChild(aimNode!)
//        
//        if indicator == 1
//        {
//            self.forceNode = SKSpriteNode(imageNamed: "Force_BLUE")
//        }else
//        {
//            self.forceNode = SKSpriteNode(imageNamed: "Force_RED")
//        }
//        self.forceNode?.position = CGPointZero
//        self.forceNode?.size = size
//        self.forceNode?.zRotation = CGFloat(rotation)
//        self.addChild(forceNode!)
//        
//        if indicator == 1
//        {
//            self.shieldNode = SKSpriteNode(imageNamed: "Shield_BLUE")
//        }
//        else
//        {
//            self.shieldNode = SKSpriteNode(imageNamed: "Shield_RED")
//        }
//        self.shieldNode?.name = "Shield"
//        self.shieldNode?.position = CGPointZero
//        self.shieldNode?.size = size
//        self.shieldNode?.zRotation = CGFloat(rotation)
//        self.addChild(shieldNode!)
//        
//        let point1 = CGPointMake(CGFloat( indicator * 43 ), CGFloat(indicator * 20))
//        
//        self.aimNode?.runAction(SKAction.moveToY(CGFloat(43 * indicator), duration: 0.3))
//        self.aimNode?.runAction(SKAction.rotateToAngle(0.0, duration: 0.3))
//        self.forceNode?.runAction(SKAction.moveTo(CGPointMake(CGFloat( indicator * 43 ), CGFloat(indicator * 20)), duration: 0.3))
//        self.forceNode?.runAction(SKAction.rotateToAngle(0.0, duration: 0.3))
//        self.shieldNode?.runAction(SKAction.moveTo(CGPointMake(CGFloat( indicator * -43 ), CGFloat(indicator * 20)), duration: 0.3))
//        self.shieldNode?.runAction(SKAction.rotateToAngle(0.0, duration: 0.3))
//    }
//    
//    func hideSkill()
//    {
//        let moveAction = SKAction.moveTo(CGPointZero, duration: 0.3)
//        let removeAction = SKAction.removeFromParent()
//        let rotateAction = SKAction.rotateToAngle(90.0, duration: 0.3)
//        self.aimNode?.runAction(SKAction.sequence([SKAction.group([moveAction,rotateAction]),removeAction]))
//        self.forceNode?.runAction(SKAction.sequence([SKAction.group([moveAction,rotateAction]),removeAction]))
//        self.shieldNode?.runAction(SKAction.sequence([SKAction.group([moveAction,rotateAction]),removeAction]))
//    }
//
//    func showShield()
//    {
//        self.hideSkill()
//        self.drawShield()
//    }
    
    // MARK: living state
    private var dead: Bool = false;
    private weak var lastParent: SKNode? = nil
    var living: Bool {
        get {
            return !dead
        }
        set {
            // if is different from current
//            println("setting living: \(newValue) with old:\(!dead)")
            if newValue ^ !dead {
//                println("setting piece.living with newValue: \(newValue)")
                if newValue {
                    undie()
                } else {
                    die()
                }
            }
        }
    }
    
    func stopMotion() {
        physicsBody?.velocity = CGVectorMake(0,0);
    }
    
    func die(triggerAction: Bool = true) {
//        println("dying: \(dead)")
        if dead {
            return
        }
        dead = true
        removeAllActions()
        lastParent = parent
        alpha = 1.0
        if triggerAction {
            fadeOut()
        } else {
            removeFromParent()
        }
    }
    
    private func undie() {
//        println("undying: \(dead), \(lastParent)")
        if !dead {
            return
        }
        dead = false;
        removeAllActions()
        alpha = 1.0
        if parent == nil {
            lastParent?.addChild(self)
        }
    }
    
    // MARK: Touch Region
    var touchRegion: PieceTouchRegion
    var touchRadius: CGFloat {
        return touchRegion.regionRadius
    }
    
    func configureTouchRegion() {
//        var pieceTouchRegion = PieceTouchRegion(radius)
        touchRegion.node = self
//        self.touchRegion = pieceTouchRegion
        self.addChild(touchRegion)
    }
    
    // MARK: factory method
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
        case .General:
            return PieceGeneral(player)
        }
    }
    
}

extension SKNode {
    func fadeOut(fadeOutWaitTime : NSTimeInterval, fadeOutFadeTime : NSTimeInterval) {
        let waitAction = SKAction.waitForDuration(fadeOutWaitTime);
        let fadeAction = SKAction.fadeOutWithDuration(fadeOutFadeTime)
        let removeAction = SKAction.removeFromParent()
        let sequence = [waitAction, fadeAction, removeAction]
        self.runAction(SKAction.sequence(sequence))
    }
    
    func fadeTo(alpha : CGFloat, fadeOutFadeTime : NSTimeInterval) {
        let fadeOutAct = SKAction.fadeAlphaTo(alpha, duration: fadeOutFadeTime)
        let sequence = [fadeOutAct];
        self.runAction(SKAction.sequence(sequence));
    }
    
    func cancelFade(fadeOutFadeTime : NSTimeInterval) {
        let fadeOutAct = SKAction.fadeAlphaTo(1.0, duration: fadeOutFadeTime)
        let sequence = [fadeOutAct];
        self.runAction(SKAction.sequence(sequence));
    }
    
    func flash(fadeOutWaitTime : NSTimeInterval, fadeOutFadeTime : NSTimeInterval) {
        let waitAction = SKAction.waitForDuration(fadeOutWaitTime);
        let fadeOutAct = SKAction.fadeAlphaTo(0.4, duration: fadeOutFadeTime);
        let fadeInAct = SKAction.fadeInWithDuration(fadeOutFadeTime);
        let sequence = [fadeOutAct, fadeInAct];
        self.runAction(SKAction.sequence(sequence));
    }
}
