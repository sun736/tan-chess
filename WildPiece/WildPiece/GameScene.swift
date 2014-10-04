//
//  GameScene.swift
//  WildPiece
//
//  Created by Amelech on 9/26/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    //let blueSideBitMask : UInt32 = 0x01
    //let worldObject : UInt32 = 0x02
    
    let MIN_MOVEMENT_DISTANCE = 50.0
    let kDISTANCE_TO_FORCE:CGFloat = -100.0
    var possibleBeginPt: CGPoint?
    var possibleEndPt: CGPoint?
    var possibleTouchNode :SKNode?
    
    override func didMoveToView(view: SKView) {
        //draw the rectange gameboard
        var yourline = SKShapeNode();
        var pathToDraw = CGPathCreateMutable();
        CGPathMoveToPoint(pathToDraw, nil, 40.0, 40.0);
        CGPathAddLineToPoint(pathToDraw, nil, 40.0, 627.0);
        CGPathAddLineToPoint(pathToDraw, nil, 335.0, 627.0);
        CGPathAddLineToPoint(pathToDraw, nil, 335.0, 40.0);
        CGPathAddLineToPoint(pathToDraw, nil, 40.0, 40.0);
        yourline.path = pathToDraw;
        yourline.strokeColor = UIColor.blueColor()
        self.addChild(yourline)
        println("Move game scene to view")
        
        //change scene background color
        scene?.backgroundColor = UIColor.lightGrayColor()
        
        scene?.physicsBody?.dynamic = false
        
        self.physicsWorld.gravity.dy = 0
        self.physicsBody?.friction = 0.9
        
        //Just for demo purpose
        //initialize blue pieces
        let blueKing = PieceKing(collisionBitMask: Piece.BITMASK_BLUE())
        let bluePawn1 = PiecePawn(collisionBitMask: Piece.BITMASK_BLUE())
        let bluePawn2 = PiecePawn(collisionBitMask: Piece.BITMASK_BLUE())
        let bluePawn3 = PiecePawn(collisionBitMask: Piece.BITMASK_BLUE())
        
        let blueElephant1 = PieceElephant(collisionBitMask: Piece.BITMASK_BLUE())
        let blueElephant2 = PieceElephant(collisionBitMask: Piece.BITMASK_BLUE())
        var blueKingLocation = CGPointMake(187, 100)
        var bluePawn1Location = CGPointMake(107, 220)
        var bluePawn2Location = CGPointMake(267, 220)
        var bluePawn3Location = CGPointMake(187, 220)
        var blueElephant1Location = CGPointMake(150, 160)
        var blueElephant2Location = CGPointMake(224, 160)

        blueKing.position = blueKingLocation
        bluePawn1.position = bluePawn1Location
        bluePawn2.position = bluePawn2Location
        bluePawn3.position = bluePawn3Location
        blueElephant1.position = blueElephant1Location
        blueElephant2.position = blueElephant2Location
        self.addChild(blueKing)
        self.addChild(bluePawn1)
        self.addChild(bluePawn2)
        self.addChild(bluePawn3)
        self.addChild(blueElephant1)
        self.addChild(blueElephant2)
        
        //initialize red pieces
        let redKing = PieceKing(collisionBitMask: Piece.BITMASK_RED())
        let redPawn1 = PiecePawn(collisionBitMask: Piece.BITMASK_RED())
        let redPawn2 = PiecePawn(collisionBitMask: Piece.BITMASK_RED())
        let redPawn3 = PiecePawn(collisionBitMask: Piece.BITMASK_RED())
        let redElephant1 = PieceElephant(collisionBitMask: Piece.BITMASK_RED())
        let redElephant2 = PieceElephant(collisionBitMask: Piece.BITMASK_RED())
        
        var redKingLocation = CGPointMake(187, 567)
        var redPawn1Location = CGPointMake(107, 447)
        var redPawn3Location = CGPointMake(187, 447)
        var redPawn2Location = CGPointMake(267, 447)
        var redElephant1Location = CGPointMake(150, 507)
        var redElephant2Location = CGPointMake(224, 507)
        redKing.position = redKingLocation
        redPawn1.position = redPawn1Location
        redPawn2.position = redPawn2Location
        redPawn3.position = redPawn3Location
        redElephant1.position = redElephant1Location
        redElephant2.position = redElephant2Location
        self.addChild(redKing)
        self.addChild(redPawn1)
        self.addChild(redPawn2)
        self.addChild(redPawn3)
        self.addChild(redElephant1)
        self.addChild(redElephant2)
        
        self.physicsWorld.contactDelegate = self
    }
    
    func didTwoBallCollision(#contacter: Piece, contactee: Piece) {
        
        contactee.deduceHealth()
        
        if contacter.healthPoint == 0 {
            contacter.fadeOut();
        }
        
        if contactee.healthPoint == 0 {
         contactee.fadeOut()
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        if (contact.bodyA.node != nil && contact.bodyB.node != nil){
            var node1 : Piece
            var node2 : Piece
            if(contact.bodyA?.categoryBitMask == Piece.BITMASK_BLUE() && contact.bodyB?.categoryBitMask == Piece.BITMASK_RED() ) {
                node1 = contact.bodyA.node as Piece
                node2 = contact.bodyB.node as Piece
            }
            else if(contact.bodyA?.categoryBitMask == Piece.BITMASK_RED() && contact.bodyB?.categoryBitMask == Piece.BITMASK_BLUE() ) {
                node1 = contact.bodyB.node as Piece
                node2 = contact.bodyA.node as Piece
            }
            else{
                return
            }
            
            if node1.isContacter {
                didTwoBallCollision(contacter: node1, contactee: node2)
            } else {
                didTwoBallCollision(contacter: node2, contactee: node1)
            }
            
            node1.drawHPRing()
            node2.drawHPRing()
        }
    }
    
    func setContacter(contacter: Piece) {
        // set all pieces to contactee
        var pieces = scene?.children
        for node in pieces as [SKNode] {
            if node.name == "piece" {
                let piece = node as Piece
                piece.isContacter = false
            }
        }
        //set clicked piece to contacter
        contacter.isContacter = true
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let nodes = self.nodesAtPoint(location)
            for node in nodes {
                if let piece = node as? Piece {
                    
                    possibleBeginPt = location
                    possibleEndPt = nil
                    possibleTouchNode = piece
                    
                    if let piece = possibleTouchNode as? Piece {
                        piece.drawRing()
                    }
                    break
                }
            }
            if let piece = possibleTouchNode as? Piece {
                piece.drawRing()
                // temporary solution to determine contacter
                setContacter(piece)
            }

        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            // save end location
            possibleEndPt = location
        }
        // fire
        if let actualBeginPt = possibleBeginPt {
            if let actualEndPt = possibleEndPt {
                if let actualTouchNode = possibleTouchNode {
                    firePull(actualTouchNode, touchBeginPt: actualBeginPt, touchEndPt: actualEndPt)
                }
            }
        }
        if let piece = possibleTouchNode as? Piece {
            piece.removeRing()
            piece.removeArrow()
        }
        
        possibleBeginPt = nil
        possibleEndPt = nil
        possibleTouchNode = nil
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            // notify the node to draw a force indicator
            if let actualBeginPt = possibleBeginPt {
                if let actualTouchNode = possibleTouchNode {
                    pullDidChangeDistance(actualTouchNode, touchBeginPt: actualBeginPt, touchEndPt: location)
                }
            }
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        if let piece = possibleTouchNode as? Piece {
            piece.removeRing()
            piece.removeArrow()
        }
        
        possibleBeginPt = nil
        possibleEndPt = nil
        possibleTouchNode = nil
    }
    
    func pullDidChangeDistance (touchNode: SKNode, touchBeginPt: CGPoint, touchEndPt: CGPoint) {
        // use node's center point as start point of force
        let centerPt = touchNode.position
        let distance = CGVectorMake(touchEndPt.x - centerPt.x, touchEndPt.y - centerPt.y)
        var force = CGVectorMake(distance.dx * kDISTANCE_TO_FORCE, distance.dy * kDISTANCE_TO_FORCE)
        if let piece = touchNode as? Piece {
            piece.drawArrow(force)
        }
    }
    
    // called when a pull gesture is performed on a node
    func firePull(touchNode: SKNode, touchBeginPt: CGPoint, touchEndPt: CGPoint) {
        
        if let piece = touchNode as? Piece {
            let centerPt = touchNode.position
            let distance = CGVectorMake(touchEndPt.x - centerPt.x, touchEndPt.y - centerPt.y)
            // do nothing if end point lies within the node border
            if (hypotf(Float(distance.dx), Float(distance.dy)) <= Float(piece.radius)) {
                return
            }
            // println(String(format:"%@, %f, %f", touchNode,  Float(distance.dx), Float(distance.dy)))
            var force = CGVectorMake(distance.dx * kDISTANCE_TO_FORCE, distance.dy * kDISTANCE_TO_FORCE)
            touchNode.physicsBody?.applyImpulse(force);
        }
    }
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        var pieces = scene?.children
        var piece: AnyObject
        
        for node in pieces as [SKNode] {
            if node.name == "piece" {
                let piece = node as Piece
                //println("x:\(piece.position.x), y:\(piece.position.y)")
                if piece.position.x < 40 || piece.position.x > 335 {
                    piece.fadeOut()
                }
                if piece.position.y < 40 || piece.position.y > 627 {
                    piece.fadeOut()
                }
                
            }
        }
    }
}
