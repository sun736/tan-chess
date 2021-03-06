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
//        println(contacter)
//        println(contactee)
        
        if contacter.pieceType != PieceType.King && contactee.pieceType != PieceType.King{
            contactee.deduceHealthToDeath()
            if contactee.pieceType != PieceType.King && contactee.healthPoint == 0{
                contactee.physicsBody?.categoryBitMask = Piece.BITMASK_TRANS()
                contactee.physicsBody?.collisionBitMask = Board.BITMASK_BOARD()
                contactee.physicsBody?.contactTestBitMask = 0x00
            }
            cancelContacter(scene, player: contacter.player)
        } else if contacter.pieceType != PieceType.King && contactee.pieceType == PieceType.King{
            contactee.deduceHealth()
            cancelContacter(scene, player: contacter.player)
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
            contactee.die()
            scene.board?.increaseSkill(contactee.player.opponent())
        }
    }
    
    class func cancelContacter (scene: GameScene, player: Player) {
        for piece in scene.piecesOfPlayer(player) {
            piece.isContacter = false;
        }
    }
    
    class func setContacter (scene: GameScene, contacter: Piece) {
        for piece in scene.pieces {
            piece.isContacter = false;
        }
        contacter.isContacter = true;
    }
    
    class func setContacters(scene: GameScene, contacter: Piece) {
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
    
    class func cancelTransparent(piece: Piece) {
        piece.physicsBody?.categoryBitMask = piece.player.bitMask
        piece.physicsBody?.collisionBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_RED() | Piece.BITMASK_EXPLOSION() | Piece.BITMASK_BULLET() | Board.BITMASK_BOARD()
        piece.physicsBody?.contactTestBitMask = Piece.BITMASK_RED() | Piece.BITMASK_BLUE() | Piece.BITMASK_TRANS()
        piece.cancelFade()
    }
    
    class func cancelAllTrans(scene: GameScene) {
        for piece in scene.transPieces {
            cancelTransparent(piece)
        }
        scene.transPieces.removeAll(keepCapacity: true)
    }
    
    class func setTransparent(scene: GameScene, piece: Piece) {
        setTransparent(piece)
        scene.transPieces.append(piece)
    }
    
    class func setTransparent(piece: Piece) {
        piece.physicsBody?.categoryBitMask = Piece.BITMASK_TRANS()
        piece.physicsBody?.collisionBitMask = Board.BITMASK_BOARD()
        piece.physicsBody?.contactTestBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_RED() | Piece.BITMASK_TRANS()
        piece.fadeTo()
    }
    
    class func cancelAllFade(scene: GameScene) {
        for piece in scene.pieces {
            piece.cancelFade()
        }
    }
    
    class func setExplosionPiece(piece: Piece) {
        piece.physicsBody?.categoryBitMask = Piece.BITMASK_EXPLOSION()
        piece.physicsBody?.collisionBitMask = Piece.BITMASK_RED() | Piece.BITMASK_BLUE() | Board.BITMASK_BOARD()
        piece.physicsBody?.contactTestBitMask = 0x00
    }
    
    class func handlContact(scene: GameScene, contact: SKPhysicsContact) {
        
        if (contact.bodyA.node != nil && contact.bodyB.node != nil){
            var node1 : Piece
            var node2 : Piece
            /*
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
                //println("transPiece: \(transPiece)")
                //println("regPiece: \(regPiece)")
                
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
            }*/
            
            //add collision sound here
            //var effectPlayer = Sound()
            //effectPlayer.playEffect()
            let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
            appDelegate.gameScene?.playSoundEffect()

//            println("node1 category: node1:  \(toBinary(contact.bodyA?.categoryBitMask))")
//            println("node1 bitmask: node1:  \(toBinary(contact.bodyA?.collisionBitMask))")
//            println("node2 category: node2: \(toBinary(contact.bodyB?.categoryBitMask))")
//            println("node2 bitmask: node2: \(toBinary(contact.bodyB?.collisionBitMask))")
            
            if(contact.bodyA?.categoryBitMask == Piece.BITMASK_BLUE() && contact.bodyB?.categoryBitMask == Piece.BITMASK_RED() ) {
                node1 = contact.bodyA.node as Piece
                node2 = contact.bodyB.node as Piece
            }
            else if(contact.bodyA?.categoryBitMask == Piece.BITMASK_RED() && contact.bodyB?.categoryBitMask == Piece.BITMASK_BLUE() ) {
                node1 = contact.bodyB.node as Piece
                node2 = contact.bodyA.node as Piece
            }
            else{
                //println("an unhandled collision occurred")
                return
            }
            
            if node1.isContacter {
                //println("node1 is contacter: \(node1)")
                didTwoBallCollision(scene: scene, contacter: node1, contactee: node2)
            } else if node2.isContacter {
                //println("node2 is contacter: \(node2)")
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
    
    class func toBinary(val: UInt32?) -> String {
        var res = ""
        
        var v:UInt32? = val
        if nil != v {
            while(v > 0) {
                if v!%2 == 1 {
                    res = "1" + res
                } else {
                    res = "0" + res
                }
                v = v!/2
            }
        }
        return res
    }
}