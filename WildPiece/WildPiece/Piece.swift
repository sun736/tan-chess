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
        physicsBody?.dynamic = true;
        
        physicsBody?.restitution = 0.5
        physicsBody?.linearDamping = 5
        physicsBody?.mass = 5;
        physicsBody?.density = 10;
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
}