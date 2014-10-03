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
    let opacity :CGFloat = 1
    let color: UInt = 0x00FFFF
    
    init(_ location: CGPoint, _ radius: CGFloat) {
        super.init()
        var path = CGPathCreateMutable()
        CGPathAddArc(path, nil, 0, 0, radius + delta, 0, CGFloat(M_PI)*2, true)
        CGPathCloseSubpath(path)
        
        self.path = path
        self.lineWidth = 2.0
        self.strokeColor = UIColor.UIColorFromRGB(color, alpha: opacity)
        self.position = location
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIColor {
    class func UIColorFromRGB(rgbValue: UInt, alpha: CGFloat) -> UIColor {
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(alpha)
        )
    }
}
