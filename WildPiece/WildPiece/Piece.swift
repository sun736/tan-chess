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
        CGPathAddArc(_path, nil, 0, 100, 45, 0, CGFloat(M_PI*2), true);
        path = _path;
        lineWidth = 2.0;
        fillColor = UIColor.blueColor();
        physicsBody = SKPhysicsBody(circleOfRadius:45)
        physicsBody?.restitution = 0.5
        physicsBody?.linearDamping = 0.0
        physicsBody?.dynamic = true;
        physicsBody?.mass = 1;
        physicsBody?.friction = 0.2;
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
}