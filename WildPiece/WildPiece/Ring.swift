//
//  Ring.swift
//  WildPiece
//
//  Created by Guocheng Xie on 9/26/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

class Ring: SKShapeNode {
    
    let delta :CGFloat = 20
    let opacity :CGFloat = 1.0
    
    init(_ location: CGPoint, _ radius: CGFloat) {
        super.init()
        var path = CGPathCreateMutable()
        CGPathAddArc(path, nil, 0, 0, radius + delta, 0, CGFloat(M_PI)*2, true)
        CGPathCloseSubpath(path)
        
        self.physicsBody = SKPhysicsBody(edgeLoopFromPath: path)
        self.lineWidth = 1.0
        self.strokeColor = UIColor.blueColor().colorWithAlphaComponent(opacity)
        self.fillColor = UIColor.redColor().colorWithAlphaComponent(opacity)
        self.position = location
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
