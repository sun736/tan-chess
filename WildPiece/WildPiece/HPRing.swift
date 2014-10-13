//
//  HPRing.swift
//  WildPiece
//
//  Created by Guocheng Xie on 10/3/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

class HPRing: SKShapeNode {
    
    let delta :CGFloat = 0
    let opacity :CGFloat = 1
    let color: UInt = 0xFF0000
    let linewidth : CGFloat = 1.5
    var radius: CGFloat = 0
    
    init(location: CGPoint, radius: CGFloat, hp: CGFloat, maxHp: CGFloat, color: UIColor) {
        super.init()
        var path = CGPathCreateMutable()
        self.radius += radius + delta
        var percentage = hp/maxHp
        if(percentage != 1 && percentage != 0) {
            percentage = 1 - percentage
        }
        CGPathAddArc(path, nil, 0, 0, self.radius, 0, CGFloat(M_PI) * 2 * percentage, true)
        self.physicsBody = nil
        self.path = path
        self.lineWidth = linewidth
        self.strokeColor = color
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
