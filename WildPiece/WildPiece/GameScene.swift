//
//  GameScene.swift
//  WildPiece
//
//  Created by Amelech on 9/26/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    let sphereObject : UInt32 = 0x01
    let worldObject : UInt32 = 0x02
    
    let MIN_MOVEMENT_DISTANCE = 50.0
    let kDISTANCE_TO_FORCE:CGFloat = -100.0
    var possibleBeginPt: CGPoint?
    var possibleEndPt: CGPoint?
    var possibleTouchNode :SKNode?
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 65
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        // Now make the edges of the screen a physics object as well
        scene?.physicsBody = SKPhysicsBody(edgeLoopFromRect: view.frame);
        //scene?.physicsBody = SKPhysicsBody(rectangleOfSize: view.frame.size, center: CGPointMake(0,0));
        
        scene?.physicsBody?.collisionBitMask = worldObject
        scene?.physicsBody?.contactTestBitMask = worldObject
        
        scene?.physicsBody?.dynamic = false
        
        self.physicsWorld.gravity.dy = 0
        self.physicsBody?.friction = 0.9
        
        //initialize piece
        //King
        let king = PieceKing();
        var location = CGPointMake(500, 200)
        king.position = location
        king.physicsBody?.categoryBitMask = sphereObject
        king.physicsBody?.contactTestBitMask = sphereObject
        king.physicsBody?.collisionBitMask = sphereObject
        self.addChild(king)
        //Pawn
        let pawn1 = PiecePawn()
        let pawn2 = PiecePawn()
        var location2 = CGPointMake(200, 50)
        pawn1.position = location2
        pawn1.physicsBody?.categoryBitMask = sphereObject
        pawn1.physicsBody?.contactTestBitMask = sphereObject
        pawn1.physicsBody?.collisionBitMask = sphereObject
        self.addChild(pawn1)
        var location3 = CGPointMake(200, 200)
        pawn2.position = location3
        pawn2.physicsBody?.categoryBitMask = sphereObject
        pawn2.physicsBody?.contactTestBitMask = sphereObject
        pawn2.physicsBody?.collisionBitMask = sphereObject
        //println("Width: \(pawn2.size.width)")
        //println("Height: \(pawn2.getRadius())")
        self.addChild(pawn2)
        //self.addChild(myLabel)
        
        self.physicsWorld.contactDelegate = self
    }
    
    func didTwoBallCollision(node1: Piece , node2: Piece) {
        println("detected")
        
        node1.deduceHealth()
        
        if node1.healthPoint == 0 {
            node1.removeFromParent()
        }
        
        if node2.healthPoint == 0 {
            node2.removeFromParent()
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        println("detected 1")
        if (contact.bodyA.node != nil && contact.bodyB.node != nil && contact.bodyA?.categoryBitMask == sphereObject && contact.bodyB?.categoryBitMask == sphereObject ) {
            let node1:Piece = contact.bodyA.node as Piece
            let node2:Piece = contact.bodyB.node as Piece
            didTwoBallCollision(node1, node2: node2)
            
        }
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let ball1 = PiecePawn();
            
            possibleBeginPt = location
            possibleEndPt = nil
            possibleTouchNode = self.nodeAtPoint(location)
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
}
