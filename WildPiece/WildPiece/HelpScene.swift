//
//  HelpScene.swift
//  WildPiece
//
//  Created by Liu Yixiang on 10/3/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import UIKit
import SpriteKit

class HelpScene: SKScene {
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        let myLabel = SKLabelNode(fontNamed:"Chalkduster")
        myLabel.text = "Game Help";
        myLabel.fontSize = 25;
        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.5);
        self.addChild(myLabel)
        
        let backButton = SKSpriteNode(imageNamed: "backbutton")
        backButton.name = "backButton"
        backButton.position = CGPoint(x:CGRectGetMidX(self.frame)*0.2, y:CGRectGetMidY(self.frame)*1.7);
        self.addChild(backButton)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        println("touch help scene")
        /* Called when a touch begins */
        super.touchesBegan(touches, withEvent: event)
        let location = touches.anyObject()?.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location!)
        
        if touchedNode.name == "backButton"
        {
            println("back to menu")
            var menuScene = MenuScene(size: self.size)
            let transition = SKTransition.revealWithDirection(SKTransitionDirection.Right, duration: 0.3)
            menuScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene?.view?.presentScene(menuScene, transition: transition)
        }
        
    }
    
}
