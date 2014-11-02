//
//  PauseScene.swift
//  WildPiece
//
//  Created by Liu Yixiang on 10/3/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import UIKit
import SpriteKit

class PauseScene: SKScene {
    
    var top : SKSpriteNode?
    var bottom : SKSpriteNode?
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = UIColor(red: 150.0/255.0, green: 212.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        
        let resumeButton = SKSpriteNode(imageNamed: "resumeButton")
        resumeButton.name = "resumeButton"
        resumeButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.2);
        self.addChild(resumeButton)
        
        let restartButton = SKSpriteNode(imageNamed: "restartButton")
        restartButton.name = "restartButton"
        restartButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.0);
        self.addChild(restartButton)
        
        let backButton = SKSpriteNode(imageNamed: "menu")
        backButton.name = "backButton"
        backButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*0.8);
        self.addChild(backButton)

        top?.runAction(SKAction.moveToY(CGFloat(600), duration: 0.2))
        bottom?.runAction(SKAction.moveToY(CGFloat(70), duration: 0.2))

    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        println("touch resume scene")
        /* Called when a touch begins */
        super.touchesBegan(touches, withEvent: event)
        let location = touches.anyObject()?.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location!)
        
        if touchedNode.name == "backButton"
        {
            println("back to menu")
            NSNotificationCenter.defaultCenter().postNotificationName(kShouldPresentMenuSceneNotification, object: self, userInfo: nil)
        }else if touchedNode.name == "restartButton"
        {
            println("restart game")
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            var gameScene = appDelegate.gameScene
            gameScene?.restartGame()
            let transition = SKTransition.crossFadeWithDuration(0.3)
            self.scene?.view?.presentScene(gameScene, transition: transition)
        }else
        {   //if resume the game, change to the old game scene in appdelegate
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            var gameScene = appDelegate.gameScene
           
            
            
            top?.runAction(SKAction.moveToY(CGFloat(CGRectGetMidY(self.frame)*1.5), duration: 0.2))
            bottom?.runAction(SKAction.moveToY(CGFloat(CGRectGetMidY(self.frame)*0.5), duration: 0.2), completion: { gameScene?.unpauseGame()
                self.scene?.view?.presentScene(gameScene)})
            //bottom?.runAction(SKAction.moveToY(CGFloat(CGRectGetMidY(self.frame)*0.5), duration: 0.2))
        }
        
    }
    
    func setTopAndBottomImage(top: UIImage, bottom: UIImage)
    {
        self.top = SKSpriteNode(texture: SKTexture(image: top))
        self.top?.size = CGSizeMake(self.frame.size.width, self.frame.size.height/2)
        self.top?.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.5);
        self.top?.zPosition = 10.0
        self.addChild(self.top!)
        
        self.bottom = SKSpriteNode(texture: SKTexture(image: bottom))
        self.bottom?.size = CGSizeMake(self.frame.size.width, self.frame.size.height/2)
        self.bottom?.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*0.5);
        self.bottom?.zPosition = 10.0
        self.addChild(self.bottom!)
    }

}
