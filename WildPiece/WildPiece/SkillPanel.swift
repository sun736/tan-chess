//
//  SkillPanel.swift
//  WildPiece
//
//  Created by Liu Yixiang on 11/12/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import UIKit
import SpriteKit

class SkillPanel: SKSpriteNode {
    var backgroundNode : SKSpriteNode
    var aimNode: SKSpriteNode
    var forceNode: SKSpriteNode
    var shieldNode: SKSpriteNode
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience  init(player: Player) {
        
        self.init(texture: nil, color: nil, size: CGSizeMake(1000.0, 1000.0))
       
        if player.id == 2
        {
            aimNode.texture = SKTexture(imageNamed:"Aim_RED")
            forceNode.texture = SKTexture(imageNamed:"Force_RED")
            shieldNode.texture = SKTexture(imageNamed:"Shield_RED")
            spreadSkill(-1)
        }else
        {
            spreadSkill(1)
        }
    }

    
    override init(texture: SKTexture!, color: UIColor!, size: CGSize)
    {
        backgroundNode = SKSpriteNode(imageNamed:"1")
        aimNode = SKSpriteNode(imageNamed:"Aim_BLUE");
        forceNode = SKSpriteNode(imageNamed:"Force_BLUE");
        shieldNode = SKSpriteNode(imageNamed:"Shield_BLUE");

        
        
        super.init(texture: texture, color: color, size: size)
        
        backgroundNode.color = UIColor.blackColor()
        backgroundNode.alpha = 0.5
        backgroundNode.size = size
        backgroundNode.zPosition = 5
        backgroundNode.name = "skillPanel"
        self.addChild(backgroundNode)
        
        aimNode.name = "Aim"
        aimNode.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        aimNode.zPosition = 6
        self.addChild(aimNode)
        
        forceNode.name = "Force"
        forceNode.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        forceNode.zPosition = 6
        self.addChild(forceNode)
        
        shieldNode.name = "Shield"
        shieldNode.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        shieldNode.zPosition = 6
        self.addChild(shieldNode)

        
    }
    
    func spreadSkill(indicator : Int){
        
        self.aimNode.runAction(SKAction.moveToY(CGFloat(50 * indicator), duration: 0.3))
        
        self.forceNode.runAction(SKAction.moveTo(CGPointMake(CGFloat( indicator * 43 ), CGFloat(indicator * -25)), duration: 0.3))
        
        self.shieldNode.runAction(SKAction.moveTo(CGPointMake(CGFloat( indicator * -43 ), CGFloat(indicator * -25)), duration: 0.3))
        
    }
    
    func hideSkill(){
        
        self.aimNode.runAction(SKAction.moveTo(CGPointZero, duration: 0.3))
        self.forceNode.runAction(SKAction.moveTo(CGPointZero, duration: 0.3))
        
        self.shieldNode.runAction(SKAction.moveTo(CGPointZero, duration: 0.3),  completion: {self.removeFromParent()})
    }
}
