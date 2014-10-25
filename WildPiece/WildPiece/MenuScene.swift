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

        var bgImage = SKSpriteNode(imageNamed: "background.jpg")
        bgImage.position = CGPointMake(self.size.width/2, self.size.height/2)
        self.addChild(bgImage)
        
        let gamtTitle = SKLabelNode(fontNamed:"Chalkduster")
        gamtTitle.text = "Tan Chess";
        gamtTitle.color = UIColor.blackColor()
        gamtTitle.fontSize = 30;
        gamtTitle.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.6);
        self.addChild(gamtTitle)
        
        let startButton = SKSpriteNode(imageNamed: "start")
        startButton.name = "startButton"
        startButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.3);
        self.addChild(startButton)
        
        let helpButton = SKSpriteNode(imageNamed: "help")
        helpButton.name = "helpButton"
        helpButton.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*0.8);
        self.addChild(helpButton)

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
            let transition = SKTransition.crossFadeWithDuration(0.3)
            self.scene?.view?.presentScene(gameScene, transition: transition)
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
