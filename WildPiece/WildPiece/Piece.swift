//
//  Piece.swift
//  WildPiece
//
//  Created by Amelech on 9/26/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

class Piece: SKShapeNode {
   
    override init() {
        super.init()
        var _path = CGPathCreateMutable();
        CGPathAddArc(_path, nil, 0, 0, 20, 0, CGFloat(M_PI*2), true);
        path = _path;
        lineWidth = 2.0;
        fillColor = UIColor.blueColor();
        physicsBody = SKPhysicsBody(circleOfRadius:20)
        physicsBody?.restitution = 0.9
        physicsBody?.linearDamping = 0.1
        physicsBody?.dynamic = true;
        physicsBody?.mass = 10;
        physicsBody?.friction = 0.9;
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
}