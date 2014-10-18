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
            
            if(contact.bodyA.categoryBitMask == 0x00) {
                var node = contact.bodyA.node as PieceCanon
                let v = hypotf(Float(node.physicsBody!.velocity.dx), Float(node.physicsBody!.velocity.dy))
                //print("here at A:\(node.player.bitMask)\n")
                let waitTime : NSTimeInterval = NSTimeInterval((10000 - v) * 0.00000001)
                let wait  = SKAction.waitForDuration(waitTime)
                let resetMask = SKAction.runBlock({
                    node.physicsBody?.categoryBitMask = node.player.bitMask
                    node.physicsBody?.collisionBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_RED()
                })
                let sequence = SKAction.sequence([wait, resetMask])
                scene.runAction(sequence)
                //print("reset at A\n")
                //print("here at A:\(node.physicsBody?.collisionBitMask)\n")
                //print("here at A:\(node.physicsBody?.categoryBitMask)\n")
                return
            } else if (contact.bodyB.categoryBitMask == 0x00) {
                
                var node = contact.bodyB.node as PieceCanon
                let v = hypotf(Float(node.physicsBody!.velocity.dx), Float(node.physicsBody!.velocity.dy))
                //print("here at B:\(node.player.bitMask)\n")
                let waitTime : NSTimeInterval = NSTimeInterval((10000 - v) * 0.00000001)
                let wait  = SKAction.waitForDuration(waitTime)
                let resetMask = SKAction.runBlock({
                    node.physicsBody?.categoryBitMask = node.player.bitMask
                    node.physicsBody?.collisionBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_RED()
                })
                let sequence = SKAction.sequence([wait, resetMask])
                scene.runAction(sequence)
                //print("reset at B\n")
                //print("here at B:\(node.physicsBody?.collisionBitMask)\n")
                //print("here at B:\(node.physicsBody?.categoryBitMask)\n")
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
            
            if(contact.bodyA.categoryBitMask == 0x00) {
                
                var node = contact.bodyA.node as PieceCanon
                print("here at A:\(node.player.bitMask)\n")
                node.physicsBody?.categoryBitMask = node.player.bitMask
                node.physicsBody?.collisionBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_RED()
                print("reset at A\n")
                print("here at A:\(node.physicsBody?.collisionBitMask)\n")
                print("here at A:\(node.physicsBody?.categoryBitMask)\n")
                return
            } else if (contact.bodyB.categoryBitMask == 0x00) {
                
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