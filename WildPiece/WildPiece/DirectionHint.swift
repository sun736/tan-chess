//
//  DirectionHint.swift
//  WildPiece
//
//  Created by Guocheng Xie on 10/17/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

class DirectionHint : SKShapeNode{
    let lineLen: CGFloat = 50
    
    init(location: CGPoint, lineColor: UIColor) {
        super.init()
        let path = CGPathCreateMutable()
        let x = location.x
        let y = location.y
        CGPathMoveToPoint(path, nil, x, y)
        CGPathAddLineToPoint(path, nil, x, y+lineLen)
        CGPathMoveToPoint(path, nil, x, y)
        CGPathAddLineToPoint(path, nil, x, y-lineLen)
        CGPathMoveToPoint(path, nil, x, y)
        CGPathAddLineToPoint(path, nil, x+lineLen, y)
        CGPathMoveToPoint(path, nil, x, y)
        CGPathAddLineToPoint(path, nil, x-lineLen, y)
        
        self.path = path
        self.lineWidth = 1
        self.strokeColor = lineColor
    }
    
    

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}