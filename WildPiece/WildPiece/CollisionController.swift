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
            contacter.fadeOut();
        }
        if contactee.healthPoint == 0 {
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
            
            if(contact.bodyA.categoryBitMask == Piece.BITMASK_TRANS()) {
                //println(contact.bodyA.node)
                //println(contact.bodyB.node)
                if (contact.bodyA.node is PieceCanon) {
                    var canon = contact.bodyA.node as PieceCanon
                    canon.physicsBody?.categoryBitMask = canon.player.bitMask
                    canon.physicsBody?.collisionBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_RED()
                    if contact.bodyB.node is Piece {
                        var transPiece = contact.bodyB.node as Piece
                        transPiece.physicsBody?.categoryBitMask = Piece.BITMASK_TRANS();
                        transPiece.physicsBody?.collisionBitMask = Piece.BITMASK_TRANS();
                        let waitTime : NSTimeInterval = 0.01;
                        let wait = SKAction.waitForDuration(waitTime)
                        let resetMask = SKAction.runBlock({
                            transPiece.physicsBody?.categoryBitMask = transPiece.player.bitMask
                            transPiece.physicsBody?.collisionBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_RED()
                        })
                        let sequence = SKAction.sequence([wait, resetMask])
                        scene.runAction(sequence)
                    }
                }
                return
            } else if (contact.bodyB.categoryBitMask == Piece.BITMASK_TRANS()) {
                //println(contact.bodyB.node)
                //println(contact.bodyA.node)
                
                if (contact.bodyB.node is PieceCanon) {
                    var canon = contact.bodyB.node as PieceCanon
                    canon.physicsBody?.categoryBitMask = canon.player.bitMask
                    canon.physicsBody?.collisionBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_RED()
                    if contact.bodyA.node is Piece {
                        var transPiece = contact.bodyA.node as Piece
                        transPiece.physicsBody?.categoryBitMask = Piece.BITMASK_TRANS();
                        transPiece.physicsBody?.collisionBitMask = Piece.BITMASK_TRANS();
                        
                        let waitTime : NSTimeInterval = 0.01;
                        let wait = SKAction.waitForDuration(waitTime)
                        let resetMask = SKAction.runBlock({
                            transPiece.physicsBody?.categoryBitMask = transPiece.player.bitMask
                            transPiece.physicsBody?.collisionBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_BLUE()
                        })
                        let sequence = SKAction.sequence([wait, resetMask])
                        scene.runAction(sequence)
                    }
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