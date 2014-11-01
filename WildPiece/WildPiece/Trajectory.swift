//
//  Trajectory.swift
//  WildPiece
//
//  Created by Chun-Hao Lin on 11/1/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//
/*
import Foundation
import SpriteKit

class Trajectory: SKShapeNode {
    //var mass: CGFloat
    //var linearDamping: CGFloat
    
    init(startPoint :CGPoint, endPoint : CGPoint, piece: Piece, player: Player) {
        super.init()
        var nodeColor: UIColor
        if(player.bitMask == Piece.BITMASK_BLUE()){
            nodeColor = UIColor(red: 0x1D, green: 0xAB, blue: 0xFC, alpha: 1.0)
        }else{
            nodeColor = UIColor(netHex:0xFD7875, alpha: 1.0)
        }
        let node = SKSpriteNode(texture: SKTexture!, color: nodeColor, size: 0.5)
        node.position = startPoint
        self.addChild(node)
        var action = SKAction.moveTo(endPoint, duration: 0.5)
        node.runAction(action)
        
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func getImageName(piece: Piece, player: Player) -> String{
        switch piece.pieceType {
        case .Elephant:
            return (player.bitMask == Piece.BITMASK_BLUE()) ? "ElephantPiece_BLUE" : "ElephantPiece_RED"
        case .Pawn:
            return (player.bitMask == Piece.BITMASK_BLUE()) ? "PawnPiece_BLUE" : "PawnPiece_RED"
        case .Rook:
            return (player.bitMask == Piece.BITMASK_BLUE()) ? "RockPiece_BLUE" : "RockPiece_RED"
        case .King:
            return (player.bitMask == Piece.BITMASK_BLUE()) ? "KingPiece_BLUE" : "KingPiece_RED"
        case .Canon:
            return (player.bitMask == Piece.BITMASK_BLUE()) ? "QueenPiece_BLUE" : "QueenPiece_RED"
        default:
            return ""
        }
    }
    
    
}*/