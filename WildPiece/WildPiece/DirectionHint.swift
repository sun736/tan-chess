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
    
    init(location: CGPoint, lineColor: UIColor, piece: Piece) {
        super.init()
        
        self.path = createHintForType(location, piece: piece)
        self.lineWidth = 1
        self.strokeColor = lineColor
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func createHintForType(location: CGPoint, piece: Piece) -> CGPathRef{
        var path: CGPathRef
        switch piece.pieceType{
        case .Elephant:
            path = createXCross(location.x, y: location.y)
        case .Rook:
            path = createStraightCross(location.x, y: location.y)
        case .Pawn:
            let isClockWise = (piece.player == PLAYER1 ? false : true)
            path = createArc(location.x, y: location.y, isClockWise: isClockWise)
        default:
            path = createInvisibleCross(location.x, y: location.y)
        }
        return path
    }

    func createStraightCross (x: CGFloat, y: CGFloat) -> CGPathRef{
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, x, y)
        CGPathAddLineToPoint(path, nil, x, y+lineLen)
        CGPathMoveToPoint(path, nil, x, y)
        CGPathAddLineToPoint(path, nil, x, y-lineLen)
        CGPathMoveToPoint(path, nil, x, y)
        CGPathAddLineToPoint(path, nil, x+lineLen, y)
        CGPathMoveToPoint(path, nil, x, y)
        CGPathAddLineToPoint(path, nil, x-lineLen, y)
        
        return path
    }
    
    func createXCross (x: CGFloat, y: CGFloat) -> CGPathRef{
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, x, y)
        CGPathAddLineToPoint(path, nil, x+lineLen, y+lineLen)
        CGPathMoveToPoint(path, nil, x, y)
        CGPathAddLineToPoint(path, nil, x+lineLen, y-lineLen)
        CGPathMoveToPoint(path, nil, x, y)
        CGPathAddLineToPoint(path, nil, x-lineLen, y+lineLen)
        CGPathMoveToPoint(path, nil, x, y)
        CGPathAddLineToPoint(path, nil, x-lineLen, y-lineLen)
        
        return path
    }
    
    func createArc(x: CGFloat, y: CGFloat, isClockWise: Bool) -> CGPathRef {
        let path = CGPathCreateMutable()
        CGPathAddArc(path, nil, x, y, lineLen, 0, CGFloat(M_PI) * 1, isClockWise)
        
        return path
    }
    
    func createInvisibleCross (x: CGFloat, y: CGFloat) -> CGPathRef{
        let path = CGPathCreateMutable()
        CGPathMoveToPoint(path, nil, x, y)        
        return path
    }
}