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

extension UIImage {
    func imageWithOverlayColor(color : UIColor) -> UIImage {
        var rect : CGRect = CGRectMake(0.0, 0.0, self.size.width, self.size.height)
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        self.drawInRect(rect)
        
        var context : CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetBlendMode(context, kCGBlendModeSourceIn);
        
        CGContextSetFillColorWithColor(context, color.CGColor);
        CGContextFillRect(context, rect);
        
        var image : UIImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        
        return image;
    }
}