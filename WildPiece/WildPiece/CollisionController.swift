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
    
    class func didTwoBallCollision(#contacter: Piece, contactee: Piece) {
        
        contactee.deduceHealth()
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
    
    class func handlContact(contact: SKPhysicsContact) {
        
        if (contact.bodyA.node != nil && contact.bodyB.node != nil){
            var node1 : Piece
            var node2 : Piece
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
                didTwoBallCollision(contacter: node1, contactee: node2)
            } else {
                didTwoBallCollision(contacter: node2, contactee: node1)
            }
        }
        
    }
    
}