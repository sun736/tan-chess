//
//  MenuScene.swift
//  WildPiece
//
//  Created by Liu Yixiang on 9/30/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import UIKit
import SpriteKit

protocol MenuSceneDelegate: class {
    func shouldDisplayOnlineSearch()
    func advertiseBluetooth()
}

class MenuScene: SKScene {
    
    var menuDelegate : MenuSceneDelegate?
    
    override func didMoveToView(view: SKView) {

        self.backgroundColor = UIColor(red: 150.0/255.0, green: 212.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        
        self.removeAllChildren()
        
        let startButton = SKSpriteNode(imageNamed: "start")
        startButton.name = "startButton"
        startButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.2);
        
        
        let onlineButton = SKSpriteNode(imageNamed: "online")
        onlineButton.name = "onlineButton"
        onlineButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*0.8);
        

       
        let moreButton = SKLabelNode(fontNamed:"Verdana")
        moreButton.name = "more"
        moreButton.text = "more"
        moreButton.fontSize = 25
        moreButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*0.15)
        
        
        let title = SKSpriteNode(imageNamed: "title")
        title.position = CGPointMake(self.size.width/2, (self.size.height/2))
        self.addChild(title)
        title.runAction(SKAction.moveToY((CGRectGetMidY(self.frame)*1.6), duration: 0.6),completion: {
            self.addChild(startButton)
            self.addChild(onlineButton)
            self.addChild(moreButton)
        })
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        super.touchesBegan(touches, withEvent: event)
        let location = touches.anyObject()?.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location!)
        
        if touchedNode.name == "startButton" {
            Logic.sharedInstance.onlineMode = false
            self.startNewGame()
        } else if touchedNode.name == "onlineButton" {
            self.menuDelegate?.advertiseBluetooth()
            Logic.sharedInstance.onlineMode = true
            self.menuDelegate?.shouldDisplayOnlineSearch()
        } else if touchedNode.name == "more" {
            println("show help menu")
            var helpScene = HelpScene(size: self.size)
//            let transition = SKTransition.revealWithDirection(SKTransitionDirection.Up, duration: 0.3)
            let transition = SKTransition.crossFadeWithDuration(0.3)
            helpScene.scaleMode = SKSceneScaleMode.AspectFit
            self.scene?.view?.presentScene(helpScene, transition: transition)
        }
    }
    
    func startNewGame() {
        println("start")
        // when start the game, init a new game scene
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var gameScene = GameScene()
        gameScene.sceneDelegate = appDelegate.gameScene?.sceneDelegate
        appDelegate.gameScene = gameScene
        gameScene.size = self.size
        gameScene.scaleMode = SKSceneScaleMode.AspectFit
        //self.scene?.view?.presentScene(gameScene, transition: transition)
        
        //Get the snapshot of the screen
        var size : CGSize! = self.view?.frame.size
        var bounds : CGRect! = self.view?.bounds
        UIGraphicsBeginImageContext(size)
        self.view?.drawViewHierarchyInRect(bounds, afterScreenUpdates: false)
        var snapshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //cut the snapshot with top and bottom half
        var topBounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.width, bounds.height/2)
        var backgroundTop = CGImageCreateWithImageInRect(snapshot.CGImage, topBounds)
        
        var bottomBounds = CGRectMake(bounds.origin.x, bounds.origin.y + bounds.height/2, bounds.width, bounds.height/2)
        var backgroundBottom = CGImageCreateWithImageInRect(snapshot.CGImage, bottomBounds)
        
        
        gameScene.setTopAndBottomImage(UIImage(CGImage: backgroundTop)!,bottom:UIImage(CGImage: backgroundBottom)!)
        
        //present the game scene
        self.scene?.view?.presentScene(gameScene)
    }
    
}
