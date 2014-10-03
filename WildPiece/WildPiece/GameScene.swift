//
//  GameScene.swift
//  WildPiece
//
//  Created by Amelech on 9/26/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let blueSideBitMask : UInt32 = 0x01
    let worldObject : UInt32 = 0x02
    
    let MIN_MOVEMENT_DISTANCE = 50.0
    let kDISTANCE_TO_FORCE:CGFloat = -100.0
    var possibleBeginPt: CGPoint?
    var possibleEndPt: CGPoint?
    var possibleTouchNode :SKNode?
    
    override func didMoveToView(view: SKView) {
        
        // Now make the edges of the screen a physics object as well
        scene?.physicsBody = SKPhysicsBody(edgeLoopFromRect: view.frame);
        scene?.physicsBody?.collisionBitMask = worldObject
        scene?.physicsBody?.contactTestBitMask = worldObject
        
        scene?.physicsBody?.dynamic = false
        
        self.physicsWorld.gravity.dy = 0
        self.physicsBody?.friction = 0.9

        //initialize pieces
        //King
        let king = PieceKing(collisionBitMask: blueSideBitMask);
        var location = CGPointMake(500, 200)
        
        king.position = location
        self.addChild(king)
        //Pawn
        let pawn1 = PiecePawn(collisionBitMask: blueSideBitMask)
        let pawn2 = PiecePawn(collisionBitMask: blueSideBitMask)
        
        var location2 = CGPointMake(200, 50)
        pawn1.position = location2
        self.addChild(pawn1)
        
        var location3 = CGPointMake(200, 200)
        pawn2.position = location3
        self.addChild(pawn2)
        
        self.physicsWorld.contactDelegate = self
    }
    
    func didTwoBallCollision(node1: Piece , node2: Piece) {
        
        node1.deduceHealth()
        
        if node1.healthPoint == 0 {
            //node1.removeFromParent()
            node1.fadeOut();
        }
        
        if node2.healthPoint == 0 {
            //node2.removeFromParent()
            node2.fadeOut()
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {

        if (contact.bodyA.node != nil && contact.bodyB.node != nil && contact.bodyA?.categoryBitMask == blueSideBitMask && contact.bodyB?.categoryBitMask == blueSideBitMask ) {

            let node1:Piece = contact.bodyA.node as Piece
            let node2:Piece = contact.bodyB.node as Piece
            didTwoBallCollision(node1, node2: node2)
            
        }
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            possibleBeginPt = location
            possibleEndPt = nil
            possibleTouchNode = self.nodeAtPoint(location)
            
            drawRing(location)
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
        deleteRing()
        
        possibleBeginPt = nil
        possibleEndPt = nil
        possibleTouchNode = nil
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            // notify the node to draw a force indicator
            if let actualBeginPt = possibleBeginPt {
                if let actualEndPt = possibleEndPt {
                    if let actualTouchNode = possibleTouchNode {
                        pullDidChangeDistance(actualTouchNode, touchBeginPt: actualBeginPt, touchEndPt: actualEndPt)
                    }
                }
            }
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        possibleBeginPt = nil
        possibleEndPt = nil
        possibleTouchNode = nil
    }
    
    func pullDidChangeDistance (touchNode: SKNode, touchBeginPt: CGPoint, touchEndPt: CGPoint) {
        var distance = CGVectorMake(touchEndPt.x - touchBeginPt.x, touchEndPt.y - touchBeginPt.y)
        if Double(abs(distance.dx) + abs(distance.dy)) < MIN_MOVEMENT_DISTANCE {
            return
        }
        var force = CGVectorMake(distance.dx * kDISTANCE_TO_FORCE, distance.dy * kDISTANCE_TO_FORCE)
    }
    
    // called when a pull gesture is performed on a node
    func firePull(touchNode: SKNode, touchBeginPt: CGPoint, touchEndPt: CGPoint) {
        
        var distance = CGVectorMake(touchEndPt.x - touchBeginPt.x, touchEndPt.y - touchBeginPt.y)
        if Double(abs(distance.dx) + abs(distance.dy)) < MIN_MOVEMENT_DISTANCE {
            return
        }
        //        println(String(format:"%@, %f, %f", touchNode,  Float(distance.dx), Float(distance.dy)))
        var force = CGVectorMake(distance.dx * kDISTANCE_TO_FORCE, distance.dy * kDISTANCE_TO_FORCE)
        
        if touchNode.isKindOfClass(Piece) {
            touchNode.physicsBody?.applyImpulse(force);
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
    
    // draw a ring around the piece
    func drawRing(location: CGPoint) {
        let node = self.nodeAtPoint(location)
        if node.isKindOfClass(Piece) {
            let piece = node as Piece
            
            var ring = Ring(piece.position, piece.getRadius())

            if let piece = possibleTouchNode as? Piece {
                piece.ring = ring
            }
            self.addChild(ring)
        }
    }
    
    func deleteRing() {
        if let piece = possibleTouchNode as? Piece {
            piece.ring?.removeFromParent()
        }
    }
}
