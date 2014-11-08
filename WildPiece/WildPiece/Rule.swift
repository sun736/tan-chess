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

        switch piece.pieceType {
        case .Elephant:
            return reforceElephant(force)
        case .Knight:
            return reforceKnight(force)
        case .Pawn:
            return reforcePawn(force, piece: piece)
        case .Rook:
            return reforceRook(force)
        default:
            return force
        }
    }
    
    class func reforcePawn(force: CGVector ,piece: Piece) -> CGVector{
        let base: CGFloat = abs(force.dx)+abs(force.dy)
        if (piece.player.bitMask == Piece.BITMASK_RED() && force.dy < 0){
            if(abs(force.dy)>=abs(force.dx)){
                return force
            }
        }
        if (piece.player.bitMask == Piece.BITMASK_BLUE() && force.dy > 0)
        {
            if(abs(force.dy)>=abs(force.dx)){
                return force
            }
        }
        
        return CGVectorMake(000.1*force.dx/base, 000.1*force.dy/base)

    }
    
    class func reforceRook(force: CGVector) -> CGVector {
        if(abs(force.dx) > abs(force.dy)) {
            return CGVectorMake(force.dx, 0)
        } else {
            return CGVectorMake(0, force.dy)
        }
    }
    
    class func reforceKnight(force: CGVector) -> CGVector {
        return force
    }
    
    class func reforceElephant(force: CGVector) -> CGVector {
        var tmpForce: CGFloat = (abs(force.dx) + abs(force.dy))/2
        if(force.dx >= 0){
            if(force.dy >= 0){
                return CGVectorMake(tmpForce, tmpForce)
            }
            else{
                return CGVectorMake(tmpForce, -tmpForce)
            }
        }
        else{
            if(force.dy >= 0){
                return CGVectorMake(-tmpForce, tmpForce)
            }
            else{
                return CGVectorMake(-tmpForce, -tmpForce)
            }
        }
    }
    
    class func pieceIsOut(scene : GameScene, piece : Piece) -> Bool {
        if let board = scene.board {
            return board.isOut(piece.position)
        }
        return false
    }
    
    class func pawnIsInDistrictedArea(scene : GameScene, piece : Piece) -> Bool {
        if let board = scene.board {
            return board.isInRestrictedArea(piece.position, isUpSide: piece.player.isUpSide)
        }
        return false;
    }
    
    class func touchDown(scene : GameScene, piece : Piece) {
        if let piece = piece as? PiecePawn {
            scene.board?.displayRestrictedArea(piece.position, isUpTurn: piece.player.isUpSide)
        }
    }
    
    class func touchUp(scene : GameScene, piece : Piece) {
        if let piece = piece as? PiecePawn {
            scene.board?.hideRestrictedArea(piece.player.isUpSide)
        }
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
    
    class func gameShouldChangeTurn(scene : GameScene, lastMove : (piece :Piece?, step : Int)) -> (turn : Bool, piece : Bool) {
        if let piece = lastMove.piece {
            if piece.pieceType == PieceType.Knight {
                return (lastMove.step > 1, false)
            }
            if piece.pieceType == PieceType.Pawn {
                if Rule.pawnIsInDistrictedArea(scene, piece: piece) {
                    Rule.addPiece(scene, pieceType: .General, location: piece.position, player : piece.player)
                    piece.removeFromParent()
                }
            }
        }
        
        return (true, false)
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
        let leftstartPointX:CGFloat = 44
        let rightendPointX:CGFloat = scene.frame.width - leftstartPointX
        var lrdiff:CGFloat = (rightendPointX - leftstartPointX)/2
        for index:Int in 0...2 {
            addPairPieces(scene, pieceType : PieceType.Pawn, location: CGPointMake(leftstartPointX + CGFloat(index)*lrdiff, 200))
        }
        
        addPairPieces(scene, pieceType : PieceType.Canon, location: CGPointMake(leftstartPointX+(lrdiff/2), 200))
        addPairPieces(scene, pieceType : PieceType.Canon, location: CGPointMake(rightendPointX-(lrdiff/2), 200))
        
        lrdiff = (rightendPointX - leftstartPointX)/4
        addPairPieces(scene, pieceType : PieceType.Rook, location: CGPointMake(leftstartPointX, 100))
        //addPairPieces(scene, pieceType : PieceType.Knight, location: CGPointMake(leftstartPointX + lrdiff, 100))
        addPairPieces(scene, pieceType : PieceType.Elephant, location: CGPointMake(leftstartPointX + lrdiff*1, 100))
        addPairPieces(scene, pieceType : PieceType.King, location: CGPointMake(leftstartPointX + lrdiff*2, 100))
        addPairPieces(scene, pieceType : PieceType.Elephant, location: CGPointMake(leftstartPointX + lrdiff*3, 100))
        //addPairPieces(scene, pieceType : PieceType.Knight, location: CGPointMake(leftstartPointX + lrdiff*5, 100))
        addPairPieces(scene, pieceType : PieceType.Rook, location: CGPointMake(leftstartPointX + lrdiff*4, 100))
       
       
    }

    class func checkBoundary(){
        
    }
}
