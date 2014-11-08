//
//  Shield.swift
//  WildPiece
//
//  Created by Guocheng Xie on 11/7/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

class Shield: SKShapeNode {
    
    let delta :CGFloat = 10
    let opacity :CGFloat = 1
    let color: UInt = 0x669933
    var radius: CGFloat = 0
    
    init(_ location: CGPoint, _ radius: CGFloat) {
        super.init()
        var path = CGPathCreateMutable()
        self.radius += radius + delta
        CGPathAddArc(path, nil, 0, 0, self.radius, 0, CGFloat(M_PI)*2, true)
        CGPathCloseSubpath(path)
        
        self.path = path
        self.lineWidth = 3.0
        self.strokeColor = UIColor.UIColorFromRGB(color, alpha: opacity)
        self.position = location
        self.zPosition = 2

    }
    
    func getRadius() -> CGFloat {
        return radius
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
