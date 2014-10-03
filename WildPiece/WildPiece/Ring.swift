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
    
    let delta :CGFloat = 5
    let opacity :CGFloat = 0.6
    
    init(_ location: CGPoint, _ radius: CGFloat) {
        super.init()
        var path = CGPathCreateMutable()
        CGPathAddArc(path, nil, 0, 0, radius + delta, 0, CGFloat(M_PI)*2, true)
        CGPathCloseSubpath(path)
        
        self.path = path
        self.lineWidth = 3
        self.strokeColor = UIColor.redColor().colorWithAlphaComponent(opacity)
        self.fillColor = UIColor.greenColor().colorWithAlphaComponent(opacity)
        self.position = location
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
