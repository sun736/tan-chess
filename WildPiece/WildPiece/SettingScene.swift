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
    var aimOn : Bool?
    var musicButton: SKLabelNode?
    var audioButton: SKLabelNode?
    var aimButton: SKLabelNode?
    var userDefaults: NSUserDefaults?
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = UIColor(red: 150.0/255.0, green: 212.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        
        self.userDefaults = NSUserDefaults.standardUserDefaults()
      
        if (userDefaults?.valueForKey("musicOn") != nil) {
            self.musicOn = userDefaults?.valueForKey("musicOn")?.boolValue
        }
        else {
            userDefaults?.setValue(true, forKey: "musicOn")
            self.musicOn = true
        }
        
        self.musicButton = SKLabelNode(fontNamed:"Verdana")
        if self.musicOn == true {
            self.musicButton?.text = "Music: ON"
        }else
        {
            self.musicButton?.text = "Music: OFF"
        }
        self.musicButton?.name = "musicButton"
        self.musicButton?.fontSize = 25
        self.musicButton?.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.2)
        self.addChild(self.musicButton!)
        
        if (userDefaults?.valueForKey("audioOn") != nil) {
            self.audioOn = userDefaults?.valueForKey("audioOn")?.boolValue
        }
        else {
            userDefaults?.setValue(true, forKey: "audioOn")
            self.audioOn = true
        }
        
        self.audioButton = SKLabelNode(fontNamed: "Verdana")
        if self.audioOn == true{
            self.audioButton?.text = "Audio: ON"
        }else
        {
            self.audioButton?.text = "Audio: OFF"
        }
        self.audioButton?.name = "audioButton"
        self.audioButton?.fontSize = 25
        self.audioButton?.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        self.addChild(self.audioButton!)
        
        if (userDefaults?.valueForKey("aimOn") != nil)
        {
            self.aimOn = userDefaults?.valueForKey("aimOn")?.boolValue
        }else
        {
            userDefaults?.setValue(true, forKey: "aimOn")
            self.aimOn = true
        }
        
        self.aimButton = SKLabelNode (fontNamed: "Verdana")
        if self.aimOn == true
        {
            self.aimButton?.text = "Eagle Mode: ON"
        }else
        {
            self.aimButton?.text = "Eagle Mode: OFF"
        }
        self.aimButton?.name = "aimButton"
        self.aimButton?.fontSize = 25
        self.aimButton?.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*0.8)
        self.addChild(self.aimButton!)
        
        let backButton = SKLabelNode(fontNamed: "Verdana")
        backButton.name = "backButton"
        backButton.text = "Back"
        backButton.fontSize = 25
        backButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*0.6)
        self.addChild(backButton)
        
        
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        let location = touches.anyObject()?.locationInNode(self)
        let touchedNode = self.nodeAtPoint(location!)
        
        if touchedNode.name == "backButton"
        {
            println("back to menu")
            
            self.saveSetting()
            
            var helpScene = HelpScene(size: self.size)
            //let transition = SKTransition.revealWithDirection(SKTransitionDirection.Down, duration: 0.3)
            let transition = SKTransition.crossFadeWithDuration(0.3)
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
        }else if touchedNode.name == "aimButton"
        {
            if aimOn == true
            {
                self.aimOn = false
                self.aimButton?.text = "Eagle Mode: OFF"
            }else
            {
                self.aimOn = true
                self.aimButton?.text = "Eagle Mode: ON"
            }
        }
        
    }
    
    func saveSetting(){
        self.userDefaults?.setValue(self.musicOn, forKey: "musicOn")
        self.userDefaults?.setValue(self.audioOn, forKey: "audioOn")
        self.userDefaults?.setValue(self.aimOn, forKey: "aimOn")
        self.userDefaults?.synchronize()
    }


}
