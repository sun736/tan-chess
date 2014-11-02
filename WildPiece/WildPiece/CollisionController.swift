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
        for piece in scene.piecesOfPlayer(contacter.player) {
            piece.isContacter = false;
        }
        
        if contacter.pieceType != PieceType.King {
            contactee.deduceHealth()
        } else if contacter.pieceType == PieceType.King && contactee.pieceType == PieceType.King {
            contactee.deduceHealthToDeath()
        }
        contactee.drawHPRing()
        if contacter.healthPoint == 0 {
            println("fade out at CollisionControler1")
            contacter.fadeOut();
        }
        if contactee.healthPoint == 0 {
            println("fade out at CollisionControler2")
            contactee.fadeOut()
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
                
                if transPiece is PieceCanon  {
                    var canon = transPiece as PieceCanon
                    // set the piece in front of canon to transpatent
                    regPiece.physicsBody?.categoryBitMask = Piece.BITMASK_TRANS()
                    regPiece.physicsBody?.collisionBitMask = Board.BITMASK_BOARD()
                    regPiece.physicsBody?.contactTestBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_RED()
                    // change canon to a regular piece
                    canon.physicsBody?.categoryBitMask = canon.player.bitMask
                    canon.physicsBody?.collisionBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_RED() | Board.BITMASK_BOARD()
                    canon.physicsBody?.contactTestBitMask = Piece.BITMASK_RED() | Piece.BITMASK_BLUE() | Piece.BITMASK_TRANS()
                    
                    // reset the changed piece in front of canon that has been changed
                    let waitTime : NSTimeInterval = 0.3;
                    let wait = SKAction.waitForDuration(waitTime)
                    let resetMask = SKAction.runBlock({
                        regPiece.physicsBody?.categoryBitMask = regPiece.player.bitMask
                        regPiece.physicsBody?.collisionBitMask =  Piece.BITMASK_BLUE() | Piece.BITMASK_RED() | Board.BITMASK_BOARD()
                        regPiece.physicsBody?.contactTestBitMask =  Piece.BITMASK_BLUE() | Piece.BITMASK_RED() | Piece.BITMASK_TRANS()
                    })
                    let sequence = SKAction.sequence([wait, resetMask])
                    scene.runAction(sequence)
                }
                return
            }
            
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