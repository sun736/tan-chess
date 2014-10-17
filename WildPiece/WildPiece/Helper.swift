//
//  Helper.swift
//  WildPiece
//
//  Created by Kaiqi on 14/10/17.
//  Copyright (c) 2014年 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

extension CGVector {
    func projectionOn(unit : CGVector) -> CGVector {
        // a - unit vector, b - original vector, x - result projection
        let aLength = CGFloat(hypotf(Float(unit.dx), Float(unit.dy)))
        let dotProduct = self.dx * unit.dx + self.dy * unit.dy
        let bLength = CGFloat(hypotf(Float(self.dx), Float(self.dy)))
        let xLength = dotProduct / aLength
        let scaleFactor = xLength / aLength
        
        return CGVectorMake(unit.dx * scaleFactor, unit.dy * scaleFactor)
    }
}