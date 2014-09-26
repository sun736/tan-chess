//
//  Piece.swift
//  WildPiece
//
//  Created by Amelech on 9/26/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

class Piece: SKSpriteNode {
   
    init(_ img : String) {
        super.init(imageNamed: img)
        physicsBody = SKPhysicsBody(circleOfRadius:100)
        physicsBody?.restitution = 1.0
        physicsBody?.linearDamping = 0.0
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
}