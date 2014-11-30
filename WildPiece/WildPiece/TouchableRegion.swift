//
//  TouchableRegion.swift
//  WildPiece
//
//  Created by Kaiqi on 11/24/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

protocol Touchable: class {
    var position: CGPoint {get}
}

let RADIUS_EXTENSION: CGFloat = 20.0

class TouchableRegion: SKShapeNode {
    
    weak var node: Piece?
    let regionRadius: CGFloat = 0
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(_ radius: CGFloat) {
        
        super.init()
        
        self.regionRadius = radius + RADIUS_EXTENSION
        let path = CGPathCreateMutable()
        CGPathAddArc(path, nil, 0, 0, regionRadius, 0, CGFloat(M_PI)*2, true)
        CGPathCloseSubpath(path)
        
        self.path = path
        self.lineWidth = 0.0
        self.strokeColor = UIColor.whiteColor()
        self.position = CGPointMake(0, 0)
        self.zPosition = 1
    }
    
    func distance(location: CGPoint) -> CGFloat {
        if let node = node {
            return hypot(node.position.x - location.x, node.position.y - location.y)
        }
        return CGFloat(FLT_MAX)
    }
    
    func show() {
        
    }
    
    func hide() {
        
    }
}