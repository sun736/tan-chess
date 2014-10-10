//
//  Player.swift
//  WildPiece
//
//  Created by Kaiqi on 14-10-4.
//  Copyright (c) 2014年 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

// Class member are not yet supported, move out as global

// the only valid two players
let PLAYER1 = Player(id : 1), PLAYER2 = Player(id : 2)
// invalid player
private let PLAYER_NULL = Player(id : 0)

// player colors
let colors = [UIColor.yellowColor(), UIColor.blueColor(), UIColor.redColor()]

class Player : Printable {
    
    let id : Int
    var name : String
    
    var color : CGColor {
        get {
            return colors[id % 3].CGColor
        }
    }
    
    private init(id : Int) {
        self.id = id
        name = "PLAYER\(id)"
    }
    
    var bitMask : UInt32 {
        get {
            return UInt32(id)
        }
    }
    
    var description : String {
        return name
    }
    
    class func getPlayer(id : Int) -> Player {
        switch id {
        case 1:
            return PLAYER1
        case 2:
            return PLAYER2
        default:
            return PLAYER_NULL
        }
    }
    
    class func getPlayer(bitMask : UInt32) -> Player {
        return getPlayer(Int(bitMask))
    }
    
    // get the opponent
    func opponent() -> Player {
        return Player.getPlayer(3 - id)
    }
}