//
//  SettingScene.swift
//  WildPiece
//
//  Created by Liu Yixiang on 10/28/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import UIKit
import SpriteKit

class SettingScene: SKScene {

    var musicOn : Bool?
    var audioOn : Bool?
    var musicButton: SKLabelNode?
    var audioButton: SKLabelNode?
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = UIColor(red: 150.0/255.0, green: 212.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        
        self.musicOn = true
        self.musicButton = SKLabelNode(fontNamed:"Verdana")
        self.musicButton?.text = "Music: ON"
        self.musicButton?.name = "musicButton"
        self.musicButton?.fontSize = 25
        self.musicButton?.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.2)
        self.addChild(self.musicButton!)
        
        self.audioOn = true;
        self.audioButton = SKLabelNode(fontNamed: "Verdana")
        self.audioButton?.text = "Audio: ON"
        self.audioButton?.name = "audioButton"
        self.audioButton?.fontSize = 25
        self.audioButton?.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));
        self.addChild(self.audioButton!)
        
        let backButton = SKLabelNode(fontNamed: "Verdana")
        backButton.name = "backButton"
        backButton.text = "Back"
        backButton.fontSize = 25
        backButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*0.8);
        self.addChild(backButton)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        let location = touches.anyObject()?.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location!)
        
        if touchedNode.name == "backButton"
        {
            println("back to menu")
            var helpScene = HelpScene(size: self.size)
            let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 0.3)
            helpScene.scaleMode = SKSceneScaleMode.AspectFill
            self.scene?.view?.presentScene(helpScene, transition: transition)
        } else if touchedNode.name == "musicButton"
        {
            if musicOn == true
            {
                self.musicOn = false
                self.musicButton?.text = "Music: OFF"
            }else
            {
                self.musicOn = true
                self.musicButton?.text = "Music: ON"
            }
        }else if touchedNode.name == "audioButton"
        {
            if audioOn == true {
                self.audioOn = false
                self.audioButton?.text = "Audio: OFF"
            }else {
                self.audioOn = true
                self.audioButton?.text = "Audio: ON"
            }
        }
        
    }


}
