//
//  EndScene.swift
//  WildPiece
//
//  Created by Chun-Hao Lin on 10/17/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import UIKit
import SpriteKit

class EndScene: SKScene {
    override func didMoveToView(view: SKView) {
        
        //self.backgroundColor = UIColor(red: 150.0/255.0, green: 212.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        
        let gamtTitle = SKLabelNode(fontNamed:"Chalkduster")
        gamtTitle.text = "Game Over"
        gamtTitle.fontSize = 25
        gamtTitle.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.7)
        //self.addChild(gamtTitle)
        
        let restartButton = SKSpriteNode(imageNamed: "restartButton")
        restartButton.name = "restartButton"
        restartButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.2);
        self.addChild(restartButton)
        
        let backButton = SKSpriteNode(imageNamed: "menu")
        backButton.name = "backButton"
        backButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*0.8);
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
            let transition = SKTransition.crossFadeWithDuration(0.3)
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
        }
    }
    
}
