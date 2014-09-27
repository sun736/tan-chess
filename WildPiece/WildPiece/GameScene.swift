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
        
        let kingBall = PieceKing();
        var location = CGPointMake(500, 200)
        kingBall.position = location
        kingBall.physicsBody?.categoryBitMask = sphereObject
        kingBall.physicsBody?.contactTestBitMask = sphereObject
        kingBall.physicsBody?.collisionBitMask = sphereObject
        self.addChild(kingBall)
        //self.addChild(myLabel)
        
        self.physicsWorld.contactDelegate = self
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let ball1 = PiecePawn();
            
            //println(location)
            ball1.position = location
            self.addChild(ball1)
            ball1.physicsBody?.applyImpulse(CGVectorMake(10000, 0))
            
            ball1.physicsBody?.categoryBitMask = sphereObject
            ball1.physicsBody?.contactTestBitMask = sphereObject
            ball1.physicsBody?.collisionBitMask = sphereObject
            
            possibleBeginPt = location
            possibleEndPt = nil
            possibleTouchNode = self // change to touched node
        }
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
    
    func firePull(touchNode: SKNode, touchBeginPt: CGPoint, touchEndPt: CGPoint) {
        
        var vector = CGVectorMake(touchEndPt.x - touchBeginPt.x, touchEndPt.y - touchBeginPt.y)
        if Double(abs(vector.dx) + abs(vector.dy)) < MIN_MOVEMENT_DISTANCE {
            return
        }
        println(String(format:"%@, %f, %f", touchNode,  Float(vector.dx), Float(vector.dy)))
        
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
