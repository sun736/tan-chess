//
//  MenuScene.swift
//  WildPiece
//
//  Created by Liu Yixiang on 9/30/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import UIKit
import SpriteKit

class MenuScene: SKScene {
    
    
    override func didMoveToView(view: SKView) {

        var bgImageTop = SKSpriteNode(imageNamed: "background")
        bgImageTop.position = CGPointMake(self.size.width/2, (self.size.height/2))
        self.addChild(bgImageTop)
        
        /*var bgImageBottom = SKSpriteNode(imageNamed: "menuBottom")
        bgImageBottom.position = CGPointMake(self.size.width/2, (self.size.height/2)*0.5)
        self.addChild(bgImageBottom)*/
        
        let startButton = SKSpriteNode(imageNamed: "start")
        startButton.name = "startButton"
        startButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.2);
        self.addChild(startButton)
        
        let onlineButton = SKSpriteNode(imageNamed: "online")
        onlineButton.name = "onlineButton"
        onlineButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*0.8);
        self.addChild(onlineButton)

        
        let helpButton = SKSpriteNode(imageNamed: "help")
        helpButton.name = "helpButton"
        helpButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*0.8);
        //self.addChild(helpButton)

        /*var piece = Piece.newPiece(PieceType.King, player: PLAYER1);
        piece.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(piece)
        
        scene?.physicsBody?.dynamic = false
        
        self.physicsWorld.gravity.dy = 0
        self.physicsBody?.friction = 0.9
        //self.physicsWorld.contactDelegate = self*/

    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        super.touchesBegan(touches, withEvent: event)
        let location = touches.anyObject()?.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location!)
        
        if touchedNode.name == "startButton"
        {
            println("start")
            
            // when start the game, init a new game scene
           let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            appDelegate.gameScene = GameScene()
            var gameScene = appDelegate.gameScene
            gameScene?.size = self.size
            gameScene?.scaleMode = SKSceneScaleMode.AspectFill
            //self.scene?.view?.presentScene(gameScene, transition: transition)
            
            //Get the snapshot of the screen
            var size : CGSize! = self.view?.frame.size
            var bounds : CGRect! = self.view?.bounds
            UIGraphicsBeginImageContext(size)
            self.view?.drawViewHierarchyInRect(bounds, afterScreenUpdates: true)
            var snapshot = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            //cut the snapshot with top and bottom half
            var topBounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.width, bounds.height/2)
            var backgroundTop = CGImageCreateWithImageInRect(snapshot.CGImage, topBounds)
            
            var bottomBounds = CGRectMake(bounds.origin.x, bounds.origin.y + bounds.height/2, bounds.width, bounds.height/2)
            var backgroundBottom = CGImageCreateWithImageInRect(snapshot.CGImage, bottomBounds)
            
            
            gameScene?.setTopAndBottomImage(UIImage(CGImage: backgroundTop)!,bottom:UIImage(CGImage: backgroundBottom)!)
            
            //present the game scene
            self.scene?.view?.presentScene(gameScene)
            
        }else if touchedNode.name == "helpButton"
        {
            println("show help menu")
            var helpScene = HelpScene(size: self.size)
            let transition = SKTransition.crossFadeWithDuration(0.3)
            helpScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene?.view?.presentScene(helpScene, transition: transition)
        }
    }
    
    
    
}
