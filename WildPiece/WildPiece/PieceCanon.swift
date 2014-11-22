//
//  PieceCanon.swift
//  WildPiece
//
//  Created by Kaiqi on 14/10/28.
//  Copyright (c) 2014年 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

class PieceCanon : Piece{
    
    let c_radius: CGFloat = 20
    let c_healthPoint: CGFloat = 10
    let c_maxhealthPoint: CGFloat = 10
    let c_mass: CGFloat = 10
    let c_linearDamping: CGFloat = 10
    let c_angularDamping: CGFloat = 7
    let c_maxForce: CGFloat = 10000.0
    let c_bluePic: String = "QueenPiece_BLUE"
    let c_redPic: String = "QueenPiece_RED"
    let c_pieceType : PieceType = PieceType.Canon
    init(_ player : Player){
        
        let c_imageNamed = (player.bitMask == Piece.BITMASK_BLUE()) ? c_bluePic : c_redPic
        
        super.init(texture: SKTexture(imageNamed: c_imageNamed), radius: c_radius, healthPoint: c_healthPoint, maxHealthPoint : c_maxhealthPoint, player : player, mass: c_mass, linearDamping: c_linearDamping, angularDamping: c_angularDamping, maxForce : c_maxForce, pieceType : c_pieceType)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setTransparentPiece(scene: GameScene, force: CGVector, launch: Bool) {
        
        var piece_curr_position = self.position;
        var arrowEndPosition = CGPointMake(force.dx/200 + self.position.x, force.dy/200 + self.position.y)
        var piece_End_position = CGPointMake(force.dx/25 + self.position.x, force.dy/25 + self.position.y)
        var distance : Float = hypotf(Float(arrowEndPosition.x - piece_curr_position.x), Float(arrowEndPosition.y - piece_curr_position.y))
        var shift_dx = 20.0 * Float(force.dy/200) / distance
        var shift_dy = 20.0 * Float(force.dx/200) / distance
        var ray_1_start = scene.locationInScene(CGPointMake(self.position.x - CGFloat(shift_dx), self.position.y + CGFloat(shift_dy)))
        var ray_1_end = scene.locationInScene(CGPointMake(piece_End_position.x - CGFloat(shift_dx), piece_End_position.y + CGFloat(shift_dy)))
        var ray_2_start = scene.locationInScene(CGPointMake(self.position.x + CGFloat(shift_dx), self.position.y - CGFloat(shift_dy)))
        var ray_2_end = scene.locationInScene(CGPointMake(piece_End_position.x + CGFloat(shift_dx), piece_End_position.y - CGFloat(shift_dy)))
        var ray_3_start = scene.locationInScene(CGPointMake(self.position.x, self.position.y))
        var ray_3_end = scene.locationInScene(CGPointMake(piece_End_position.x, piece_End_position.y))
        
//        println("================")
//        println("vector dx:\(force.dx), dy:\(force.dy)")
//        println("piece_start\(self.position)")
//        println("piece_end(\(piece_End_position.x),\(piece_End_position.y))")
//        println("ray_1_start\(ray_1_start)")
//        println("ray_1_end\(ray_1_end)")
//        println("ray_2_start\(ray_2_start)")
//        println("ray_2_end\(ray_2_end)")
//        println("================")
        
//        for piece in scene.pieces {
//            piece.cancelFade()
//        }
        
        var body1 = scene.physicsWorld.bodyAlongRayStart(ray_1_start, end: ray_1_end)
        var body2 = scene.physicsWorld.bodyAlongRayStart(ray_2_start, end: ray_2_end)
        var body3 = scene.physicsWorld.bodyAlongRayStart(ray_3_start, end: ray_3_end)
        CollisionController.cancelAllFade(scene)
        if body1 != nil || body2 != nil{
            var distance_1 : Float = Float.infinity
            var distance_2 : Float = Float.infinity
            var distance_3 : Float = Float.infinity
            var piece1 : Piece? = body1?.node as? Piece
            var piece2 : Piece? = body2?.node as? Piece
            var piece3 : Piece? = body3?.node as? Piece
            if let piece1 = piece1 {
                distance_1 = hypotf(Float(piece1.position.x - self.position.x), Float(piece1.position.y - self.position.y))
            }
            if let piece2 = piece2 {
                distance_2 = hypotf(Float(piece2.position.x - self.position.x), Float(piece2.position.y - self.position.y))
            }
            if distance_1 != Float.infinity || distance_2 != Float.infinity {
                //CollisionController.cancelTranparent(scene)
                if distance_1 < distance_2 {
                    if piece1?.name == piece3?.name{
                        if launch {
                            CollisionController.setTransparent(piece1!)
                            CollisionController.setContacter(scene, contacter: self)
                        } else {
                            
                            piece1?.fadeTo()
                        }
                    }
                } else if distance_2 < distance_1 {
                    if piece2?.name == piece3?.name {
                        if launch {
                            CollisionController.setTransparent(piece2!)
                            CollisionController.setContacter(scene, contacter: self)
                        } else {
                            piece2?.fadeTo()
                        }
                    }
                } else if distance_1 == distance_2 {
                    if piece3?.name == piece1?.name {
                        if launch {
                            CollisionController.setTransparent(piece1!)
                            CollisionController.setContacter(scene, contacter: self)
                        } else {
                            piece1?.fadeTo()
                        }
                    }
                    if piece3?.name == piece2?.name {
                        if launch {
                            CollisionController.setTransparent(piece2!)
                            CollisionController.setContacter(scene, contacter: self)
                        } else {
                            piece2?.fadeTo()
                        }
                    }
                }
            }
        }
        //println("ray_1_find: \(body1)")
        //println("ray_2_find: \(body2)")
    }
    
}
