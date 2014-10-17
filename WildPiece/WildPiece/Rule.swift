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
    
    class func pieceValidForce(scene : GameScene, piece : Piece, force : CGVector) -> CGVector {
        return CGVectorMake(0,0)
    }
    
    class func pieceShouldOut(scene : GameScene, piece : Piece) -> Bool {
        return true;
    }
    
    class func gameIsEnd(scene : GameScene) -> (isEnd : Bool, winner : Player) {
        var winningPlayer : [Player] = [Player]()
        for player in [PLAYER1, PLAYER2] {
            var kingCount = scene.piecesOfPlayer(player).filter{$0.pieceType == PieceType.King}.count
            if kingCount == 0 {
                winningPlayer.append(player.opponent())
            }
        }
        if winningPlayer.count == 1 {
            return (true, winningPlayer[0])
        } else if winningPlayer.count == 2 {
            return (true, PLAYER_NULL)
        } else {
            return (false, PLAYER_NULL)
        }
    }
    
    // MARK: Add/Remove Pieces
    class func addPiece(scene : GameScene, pieceType : PieceType, location : CGPoint, player : Player) {
        var piece = Piece.newPiece(pieceType, player: player);
        piece.position = location
        scene.addChild(piece)
    }
    
    // add a piece for each player, with symmetrical position
    class func addPairPieces(scene : GameScene, pieceType : PieceType, location : CGPoint) {
        self.addPiece(scene, pieceType : pieceType, location: location, player: PLAYER1)
        let opponentLocation = CGPointMake(scene.size.width - location.x, scene.size.height - location.y)
        self.addPiece(scene, pieceType : pieceType, location: opponentLocation, player: PLAYER2)
    }
    
    class func placePieces(scene : GameScene) {
        
        //Just for demo purpose
        // add pawns
        //addPairPieces(scene, pieceType : PieceType.Pawn, location: CGPointMake(127, 200))
        //addPairPieces(scene, pieceType : PieceType.Pawn, location: CGPointMake(247, 200))
        addPairPieces(scene, pieceType : PieceType.Pawn, location: CGPointMake(187, 200))
        addPairPieces(scene, pieceType : PieceType.Pawn, location: CGPointMake(67, 200))
        addPairPieces(scene, pieceType : PieceType.Pawn, location: CGPointMake(307, 200))
        // add kings
        addPairPieces(scene, pieceType : PieceType.King, location: CGPointMake(187, 100))
        // add elephants
        //addPairPieces(scene, pieceType : PieceType.Elephant, location: CGPointMake(147, 100))
        addPairPieces(scene, pieceType : PieceType.Elephant, location: CGPointMake(227, 100))
        // add Knight
        addPairPieces(scene, pieceType : PieceType.Knight, location: CGPointMake(107, 100))
        //addPairPieces(scene, pieceType : PieceType.Knight, location: CGPointMake(267, 100))
        // add rocks
        addPairPieces(scene, pieceType : PieceType.Rock, location: CGPointMake(67, 100))
        //addPairPieces(scene, pieceType : PieceType.Rock, location: CGPointMake(307, 100))
        // add canons
        //addPairPieces(scene, pieceType : PieceType.Canon, location: CGPointMake(97, 150))
        addPairPieces(scene, pieceType : PieceType.Canon, location: CGPointMake(277, 150))
    }
    
    class func placeBoard(scene : GameScene) {
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
