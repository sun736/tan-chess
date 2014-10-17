//
//  Rule.swift
//  WildPiece
//
//  Created by Kaiqi on 14-10-15.
//  Copyright (c) 2014年 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

class Rule {
    
    
    init() {
        
    }
    
    class var sharedInstance : Logic {
        get {
            struct Static {
                static let instance : Logic = Logic()
            }
            return Static.instance
        }
    }
    
    func validForce(scene : GameScene, piece : Piece, force : CGVector) -> CGVector {
        return CGVectorMake(0,0)
    }
    
    func gameIsEnd(scene : GameScene) -> (isEnd : Bool, winner : Player) {
        return (true, PLAYER_NULL)
    }
    
    // MARK: Add/Remove Pieces
    func addPiece(scene : GameScene, pieceType : PieceType, location : CGPoint, player : Player) {
        var piece = Piece.newPiece(pieceType, player: player);
        piece.position = location
        scene.addChild(piece)
    }
    
    // add a piece for each player, with symmetrical position
    func addPairPieces(scene : GameScene, pieceType : PieceType, location : CGPoint) {
        self.addPiece(scene, pieceType : pieceType, location: location, player: PLAYER1)
        let opponentLocation = CGPointMake(scene.size.width - location.x, scene.size.height - location.y)
        self.addPiece(scene, pieceType : pieceType, location: opponentLocation, player: PLAYER2)
    }
    
    func placePieces(scene : GameScene) {
        
        //Just for demo purpose
        // add pawns
        addPairPieces(scene, pieceType : PieceType.Pawn, location: CGPointMake(127, 200))
        addPairPieces(scene, pieceType : PieceType.Pawn, location: CGPointMake(247, 200))
        addPairPieces(scene, pieceType : PieceType.Pawn, location: CGPointMake(187, 200))
        addPairPieces(scene, pieceType : PieceType.Pawn, location: CGPointMake(67, 200))
        addPairPieces(scene, pieceType : PieceType.Pawn, location: CGPointMake(307, 200))
        // add kings
        addPairPieces(scene, pieceType : PieceType.King, location: CGPointMake(187, 100))
        // add elephants
        addPairPieces(scene, pieceType : PieceType.Elephant, location: CGPointMake(147, 100))
        addPairPieces(scene, pieceType : PieceType.Elephant, location: CGPointMake(227, 100))
        // add Knight
        addPairPieces(scene, pieceType : PieceType.Knight, location: CGPointMake(107, 100))
        addPairPieces(scene, pieceType : PieceType.Knight, location: CGPointMake(267, 100))
        // add rocks
        addPairPieces(scene, pieceType : PieceType.Rock, location: CGPointMake(67, 100))
        addPairPieces(scene, pieceType : PieceType.Rock, location: CGPointMake(307, 100))
        // add canons
        addPairPieces(scene, pieceType : PieceType.Canon, location: CGPointMake(97, 150))
        addPairPieces(scene, pieceType : PieceType.Canon, location: CGPointMake(277, 150))
    }
    
    func placeBoard(scene : GameScene) {
        //draw the rectange gameboard
        var yourline = SKShapeNode();
        var pathToDraw = CGPathCreateMutable();
        CGPathMoveToPoint(pathToDraw, nil, 40.0, 40.0);
        CGPathAddLineToPoint(pathToDraw, nil, 40.0, 627.0);
        CGPathAddLineToPoint(pathToDraw, nil, 335.0, 627.0);
        CGPathAddLineToPoint(pathToDraw, nil, 335.0, 40.0);
        CGPathAddLineToPoint(pathToDraw, nil, 40.0, 40.0);
        yourline.path = pathToDraw;
        yourline.strokeColor = UIColor.blueColor()
        scene.addChild(yourline)
    }
}