//
//  Player.swift
//  WildPiece
//
//  Created by Kaiqi on 14-10-4.
//  Copyright (c) 2014年 Project TC. All rights reserved.
//

import Foundation

// the only valid two players
let PLAYER1 = Player(id : 1), PLAYER2 = Player(id : 2)
// invalid player
private let PLAYER_NULL = Player(id : 0)

class Player : Printable {
    
    let id : Int
    var name : String
    
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
        return PLAYER1
    }
    
    // get the opponent
    func opponent() -> Player {
        return Player.getPlayer(1 - id)
    }
}