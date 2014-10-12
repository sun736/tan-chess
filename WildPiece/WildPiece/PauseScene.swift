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
    override func didMoveToView(view: SKView) {
        
        let resumeButton = SKSpriteNode(imageNamed: "resumeButton")
        resumeButton.name = "resumeButton"
        resumeButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.3);
        self.addChild(resumeButton)
        
        let restartButton = SKSpriteNode(imageNamed: "restartButton")
        restartButton.name = "restartButton"
        restartButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.0);
        self.addChild(restartButton)
        
        let backButton = SKSpriteNode(imageNamed: "returnButton")
        backButton.name = "backButton"
        backButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*0.7);
        self.addChild(backButton)


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
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            var gameScene = appDelegate.gameScene
            gameScene?.endGame()
            var menuScene = MenuScene(size: self.size)
            let transition = SKTransition.revealWithDirection(SKTransitionDirection.Right, duration: 0.3)
            menuScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene?.view?.presentScene(menuScene, transition: transition)
            
        }else if touchedNode.name == "restartButton"
        {
            println("restart game")
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            var gameScene = appDelegate.gameScene
            gameScene?.restartGame()
            let transition = SKTransition.crossFadeWithDuration(0.3)
            self.scene?.view?.presentScene(gameScene, transition: transition)
        }else if touchedNode.name == "resumeButton"
        {
            //if resume the game, change to the old game scene in appdelegate
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            var gameScene = appDelegate.gameScene
            gameScene?.unpauseGame()
            let transition = SKTransition.crossFadeWithDuration(0.3)
            self.scene?.view?.presentScene(gameScene, transition: transition)
            
        }
        
    }

}
