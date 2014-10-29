//
//  TutorialScene.swift
//  WildPiece
//
//  Created by Liu Yixiang on 10/28/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import UIKit
import SpriteKit

class TutorialScene: SKScene {
    
    var logoImages = Array<UIImage>()
    var tutorialImage : SKSpriteNode?
    var tutorialImage2 : SKSpriteNode?
    
    override func didMoveToView(view: SKView) {
        
        self.backgroundColor = UIColor(red: 150.0/255.0, green: 212.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        
        tutorialImage = SKSpriteNode(imageNamed: "1")
        tutorialImage?.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.2);
        self.addChild(tutorialImage!)
        
        tutorialImage2 = SKSpriteNode(imageNamed: "1")
        tutorialImage2?.position = CGPoint(x:CGRectGetMidX(self.frame) * 4, y:CGRectGetMidY(self.frame)*1.2);
        self.addChild(tutorialImage2!)
        
        var swipeLeftGesture = UISwipeGestureRecognizer(target: self, action: Selector("swipe:"))
        swipeLeftGesture.direction = UISwipeGestureRecognizerDirection.Left
        self.view?.addGestureRecognizer(swipeLeftGesture)
        
        var swipeRightGesture = UISwipeGestureRecognizer(target: self, action: Selector("swipe:"))
        swipeRightGesture.direction = UISwipeGestureRecognizerDirection.Right
        self.view?.addGestureRecognizer(swipeRightGesture)
        
    }
    
     func swipe(recognizer: UISwipeGestureRecognizer)
     {
        if recognizer.state == UIGestureRecognizerState.Ended{
            switch recognizer.direction {
            case UISwipeGestureRecognizerDirection.Right:
                println("Swiped right")
                self.tutorialImage?.runAction(SKAction.moveToX(CGRectGetMidX(self.frame), duration: 0.3))
                self.tutorialImage2?.runAction(SKAction.moveToX(CGRectGetMidX(self.frame) * 4, duration: 0.3))
                break;
            case UISwipeGestureRecognizerDirection.Left:
                println("Swiped left")
                self.tutorialImage?.runAction(SKAction.moveToX(CGFloat(-160), duration: 0.3))
                self.tutorialImage2?.runAction(SKAction.moveToX(CGRectGetMidX(self.frame), duration: 0.3))
                break;
            default:
                break
            }
        }
    }

}
