//
//  Logic.swift
//  WildPiece
//
//  Created by Kaiqi on 14-10-3.
//  Copyright (c) 2014年 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

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
    
    private(set) var scene: GameScene?
    
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
    
    class var sharedInstance : Logic {
        get {
            struct Static {
                static let instance : Logic = Logic()
            }
            return Static.instance
        }
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
                    isMoving = (body.velocity.dx != 0) || (body.velocity.dy != 0)
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
                    state = .Ended(Player.getPlayer(playerFlags))
                case 0x03:
                    state = .Waiting(player.opponent())
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
    
    func startGame(gameScene : GameScene) {
        
        state = .Starting
        self.scene = gameScene
        // initiate scene
        scene?.removePieces()
        scene?.placePieces()
        
        // first player's turn
        state = .Waiting(PLAYER1)
        
        
        
    }
}