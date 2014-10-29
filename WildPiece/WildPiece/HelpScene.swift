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
        
        self.backgroundColor = UIColor(red: 150.0/255.0, green: 212.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        
        let tutorialButton = SKLabelNode(fontNamed:"Verdana")
        tutorialButton.text = "Tutorial";
        tutorialButton.name = "tutorialButton"
        tutorialButton.fontSize = 25;
        tutorialButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.2);
        self.addChild(tutorialButton)
        
        let settingButton = SKLabelNode(fontNamed: "Verdana")
        settingButton.text = "Setting"
        settingButton.name = "settingButton"
        settingButton.fontSize = 25
        settingButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(settingButton)
        
        let backButton = SKLabelNode(fontNamed: "Verdana")
        backButton.name = "backButton"
        backButton.text = "Menu"
        backButton.fontSize = 25
        backButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*0.8);
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
            let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 0.3)
            menuScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene?.view?.presentScene(menuScene, transition: transition)
        } else if touchedNode.name == "settingButton"
        {
            var settingScene = SettingScene(size: self.size)
            let transition = SKTransition.revealWithDirection(SKTransitionDirection.Up, duration: 0.3)
            settingScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene?.view?.presentScene(settingScene, transition: transition)
        } else if touchedNode.name == "tutorialButton"
        {
            var tutorialScene = TutorialScene(size: self.size)
            let transition = SKTransition.revealWithDirection(SKTransitionDirection.Up, duration: 0.3)
            tutorialScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene?.view?.presentScene(tutorialScene, transition: transition)

        }
        
    }
    
}
