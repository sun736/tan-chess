//
//  GameScene.swift
//  WildPiece
//
//  Created by Amelech on 9/26/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Hello, World!"
        myLabel.fontSize = 65
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        
        // Now make the edges of the screen a physics object as well
        scene?.physicsBody = SKPhysicsBody(edgeLoopFromRect: view.frame);
        //scene?.physicsBody = SKPhysicsBody(rectangleOfSize: view.frame.size, center: CGPointMake(0,0));
        scene?.physicsBody?.collisionBitMask = 0
        scene?.physicsBody?.dynamic = false
        
        self.physicsWorld.gravity.dy = 0
        self.physicsBody?.friction = 0.9
        self.addChild(myLabel)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let ball1 = Piece();
            let ball2 = Piece();
            ball2.physicsBody?.mass = 10
            
            ball1.position = location
            var location2 = CGPointMake(location.x, location.y+100)
            ball2.position = location2
            ball2.fillColor = UIColor.brownColor()
            
            //sprite.physicsBody?.velocity = (CGVectorMake(100, 100))
            self.addChild(ball1)
            self.addChild(ball2)
            //sprite.physicsBody?.velocity = (CGVectorMake(0, 0))
            ball1.physicsBody?.applyImpulse(CGVectorMake(1000, 0))
            ball2.physicsBody?.applyImpulse(CGVectorMake(1000, 0))
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
