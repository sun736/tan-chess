//
//  Logic.swift
//  WildPiece
//
//  Created by Kaiqi on 14-10-3.
//  Copyright (c) 2014年 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

typealias Player = Int
extension Player {
    var bitMask : UInt32 {
        get {
            return UInt32(self)
        }
    }
    
    // get the opponent
    func opponent() -> Player {
        return Player(1 - self)
    }
}
// the only two players: Player(1), Player(2)
let PLAYER1 = Player(1), PLAYER2 = Player(2)

class Logic {
    
    enum GameState : Printable {
        case Unstarted
        case Starting
        case Suspended
        case Processing(Player)
        case Waiting(Player)
        case Ended(Player)
        case Error
        
        var description : String {
            switch self {
            case .Unstarted:
                return "Unstarted"
            case .Starting:
                return "Starting"
            case .Suspended:
                return "Suspended"
            case .Processing(let player):
                return "Processing(\(player))"
            case .Waiting(let player):
                return "Waiting(\(player))"
            case .Ended(let player):
                return "Ended(\(player))"
            default:
                return "default"
            }
        }
    }
    
    var scene: GameScene? {
        didSet {
            self.startGame()
        }
    }
    private(set) var state: GameState {
        willSet {
            println("old state: \(state)")
        }
        didSet {
            println("new state: \(state)")
        }
    }
    private(set) var currentPlayer: Player?
    
    init() {
        state = .Unstarted
    }
    
    class func sharedInstance() -> Logic {
        struct Static {
            static let instance : Logic = Logic()
        }
        return Static.instance
    }
    
    func updateState() {
        
        // get pieces' states
        var children = scene?.children
        var playerFlags : UInt32 = 0x0
        var isMoving : Bool = false
        for child in children as [SKNode] {
            if let piece = child as? Piece {
                if let body = piece.physicsBody {
                    playerFlags |= body.categoryBitMask
                    isMoving = hypotf(Float(body.velocity.dx), Float(body.velocity.dy)) > 0
                }
            }
        }
        
        switch state {
        case .Unstarted:
            break
        case .Starting:
            break
        case .Suspended:
            break
        case .Processing(let player):
            if !isMoving {
                switch playerFlags {
                case 0x01, 0x02:
                    state = .Ended(Player(playerFlags))
                case 0x03:
                    state = .Waiting(player)
                default:
                    state = .Error
                }
            }
            break
        case .Waiting(let player):
            if isMoving {
                state = .Processing(player)
            }
            break
        case .Ended(let player):
            break
        default:
            state = .Error
        }
    }
    
    private func startGame() {
        
        state = .Starting
        // initiate scene
        scene?.placePieces()
        
        // first player's turn
        state = .Waiting(PLAYER1)
        
        
        
        
    }
}