//
//  CollisionController.swift
//  WildPiece
//
//  Created by Yi Sun on 10/6/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import Foundation
import SpriteKit


class CollisionController {
    
    class func didTwoBallCollision(#scene: GameScene, contacter: Piece, contactee: Piece) {
        // only one deduction collision is allowed
        println(contacter)
        println(contactee)
//        for piece in scene.piecesOfPlayer(contacter.player) {
//            piece.isContacter = false;
//        }
        
        if contacter.pieceType != PieceType.King && contactee.pieceType != PieceType.King{
            contactee.deduceHealthToDeath()
            if contactee.pieceType != PieceType.King && contactee.healthPoint == 0{
                contactee.physicsBody?.categoryBitMask = Piece.BITMASK_TRANS()
                contactee.physicsBody?.collisionBitMask = Board.BITMASK_BOARD()
                contactee.physicsBody?.contactTestBitMask = 0x00
            }
            cancelContacter(scene, contacter: contacter)
        } else if contacter.pieceType != PieceType.King && contactee.pieceType == PieceType.King{
            contactee.deduceHealth()
            cancelContacter(scene, contacter: contacter)
        }else if contacter.pieceType == PieceType.King && contactee.pieceType == PieceType.King {
            contactee.deduceHealthToDeath()
        }
        contactee.drawHPRing()
        if contacter.healthPoint == 0 {
            println("fade out at CollisionControler1")
            //contacter.fadeOut();
        }
        if contactee.healthPoint == 0 {
            println("fade out at CollisionControler2")
            contactee.fadeOut()
            scene.board?.increaseSkill(contactee.player.opponent())
        }
    }
    
    class func cancelContacter (scene: GameScene, contacter: Piece) {
        for piece in scene.piecesOfPlayer(contacter.player) {
            piece.isContacter = false;
        }
    }
    
    class func setContacter(scene: GameScene, contacter: Piece) {
        // set all pieces to contactee
        for piece in scene.pieces {
            if piece.physicsBody?.categoryBitMask == contacter.physicsBody?.categoryBitMask {
                piece.isContacter = true
            } else {
                piece.isContacter = false
            }
        }
        //set clicked piece to contacter
        contacter.isContacter = true
        
    }
    
    class func handlContact(scene: GameScene, contact: SKPhysicsContact) {
        
        if (contact.bodyA.node != nil && contact.bodyB.node != nil){
            var node1 : Piece
            var node2 : Piece
            
            if(contact.bodyA.categoryBitMask == Piece.BITMASK_TRANS() || contact.bodyB.categoryBitMask == Piece.BITMASK_TRANS()) {
                var transPiece : Piece
                var regPiece : Piece
                if (contact.bodyA.categoryBitMask == Piece.BITMASK_TRANS()) {
                    transPiece = contact.bodyA.node as Piece
                    regPiece = contact.bodyB.node as Piece
                } else {
                    transPiece = contact.bodyB.node as Piece
                    regPiece = contact.bodyA.node as Piece
                }
                println("transPiece: \(transPiece)")
                println("regPiece: \(regPiece)")
                
                //if transPiece is PieceCanon  {
                //var canon = transPiece as PieceCanon
                    // set the piece in front of canon to transpatent
                regPiece.physicsBody?.categoryBitMask = Piece.BITMASK_TRANS()
                regPiece.physicsBody?.collisionBitMask = Board.BITMASK_BOARD()
                regPiece.physicsBody?.contactTestBitMask = 0x00
                regPiece.fadeTo()
                // change canon to a regular piece
                transPiece.physicsBody?.categoryBitMask = transPiece.player.bitMask
                transPiece.physicsBody?.collisionBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_RED() | Board.BITMASK_BOARD()
                transPiece.physicsBody?.contactTestBitMask = Piece.BITMASK_RED() | Piece.BITMASK_BLUE() | Piece.BITMASK_TRANS()
                transPiece.cancelFade()
                
                // reset the changed piece in front of canon that has been changed
                //let v = hypotf(Float(transPiece.physicsBody!.velocity.dx), Float(transPiece.physicsBody!.velocity.dy))
                //println("velocity: \(v)")
                //let waitTime : NSTimeInterval = NSTimeInterval((850 - v) * 0.001)
                let waitTime : NSTimeInterval = 0.2;
                let wait = SKAction.waitForDuration(waitTime)
                let resetMask = SKAction.runBlock({
                    regPiece.physicsBody?.categoryBitMask = regPiece.player.bitMask
                    regPiece.physicsBody?.collisionBitMask =  Piece.BITMASK_BLUE() | Piece.BITMASK_RED() | Board.BITMASK_BOARD()
                    regPiece.physicsBody?.contactTestBitMask =  Piece.BITMASK_BLUE() | Piece.BITMASK_RED() | Piece.BITMASK_TRANS()
                    regPiece.cancelFade()
                })
                let sequence = SKAction.sequence([wait, resetMask])
                scene.runAction(sequence)
                //}
                return
            }
            
            //add collision sound here
            //var effectPlayer = Sound()
            //effectPlayer.playEffect()
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            appDelegate.gameScene?.runAction(SKAction.playSoundFileNamed("collision2.wav", waitForCompletion: false))
            
            if(contact.bodyA?.categoryBitMask == Piece.BITMASK_BLUE() && contact.bodyB?.categoryBitMask == Piece.BITMASK_RED() ) {
                node1 = contact.bodyA.node as Piece
                node2 = contact.bodyB.node as Piece
            }
            else if(contact.bodyA?.categoryBitMask == Piece.BITMASK_RED() && contact.bodyB?.categoryBitMask == Piece.BITMASK_BLUE() ) {
                node1 = contact.bodyB.node as Piece
                node2 = contact.bodyA.node as Piece
            }
            else{
                return
            }
            
            if node1.isContacter {
                didTwoBallCollision(scene: scene, contacter: node1, contactee: node2)
            } else if node2.isContacter {
                didTwoBallCollision(scene: scene, contacter: node2, contactee: node1)
            }
        }
        
    }
    
    class func handleEndContact(contact: SKPhysicsContact) {
        print("handle ended contact\n")
        if contact.bodyA.node != nil && contact.bodyB.node != nil {
            var node1 : Piece
            var node2 : Piece
            
            if(contact.bodyA.categoryBitMask == Piece.BITMASK_TRANS()) {
                
                var node = contact.bodyA.node as PieceCanon
                print("here at A:\(node.player.bitMask)\n")
                node.physicsBody?.categoryBitMask = node.player.bitMask
                node.physicsBody?.collisionBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_RED()
                print("reset at A\n")
                print("here at A:\(node.physicsBody?.collisionBitMask)\n")
                print("here at A:\(node.physicsBody?.categoryBitMask)\n")
                return
            } else if (contact.bodyB.categoryBitMask == Piece.BITMASK_TRANS()) {
                
                var node = contact.bodyB.node as PieceCanon
                print("here at B:\(node.player.bitMask)\n")
                node.physicsBody?.categoryBitMask = node.player.bitMask
                node.physicsBody?.collisionBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_RED()
                print("reset at B\n")
                print("here at B:\(node.physicsBody?.collisionBitMask)\n")
                print("here at B:\(node.physicsBody?.categoryBitMask)\n")
                return
            }
        }
    }
    
}