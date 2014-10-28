//
//  PieceKnight.swift
//  WildPiece
//
//  Created by Kaiqi on 14/10/28.
//  Copyright (c) 2014年 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

class PieceKnight : Piece{
    
    let c_radius: CGFloat = 20
    let c_healthPoint: CGFloat = 10
    let c_maxhealthPoint: CGFloat = 10
    let c_mass: CGFloat = 10
    let c_linearDamping: CGFloat = 10
    let c_angularDamping: CGFloat = 7
    let c_maxForce: CGFloat = 10000.0
    let c_bluePic: String = "KnightPiece_BLUE"
    let c_redPic: String = "KnightPiece_RED"
    let c_pieceType : PieceType = PieceType.Knight
    var isAttackState = false
    var startPoint: CGPoint?;
    var firstDirectionVector: CGVector?;
    
    init(_ player : Player){
        
        let c_imageNamed = (player.bitMask == Piece.BITMASK_BLUE()) ? c_bluePic : c_redPic
        
        super.init(texture: SKTexture(imageNamed: c_imageNamed), radius: c_radius, healthPoint: c_healthPoint, maxHealthPoint : c_maxhealthPoint, player : player, mass: c_mass, linearDamping: c_linearDamping, angularDamping: c_angularDamping, maxForce : c_maxForce, pieceType : c_pieceType)
        
        self.physicsBody?.restitution = 0
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
