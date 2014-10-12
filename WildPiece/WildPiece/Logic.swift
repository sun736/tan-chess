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
        case Error(String)
        
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
            case .Error(let error):
                return "Error: \(error)"
            }
        }
    }
    
    private(set) var scene: GameScene?
    
    private(set) var state: GameState {
//        willSet {
//            println("old state: \(state)")
//        }
        didSet {
            println("new state: \(state)")
        }
    }
    
    private var currentPlayer: Player? {
        get {
            switch state {
            case .Waiting(let player):
                return player
            default:
                return nil
            }
        }
    }
    
    func isWaiting(player : Player) -> Bool {
        switch state {
        case .Waiting(let waitingPlayer):
            return waitingPlayer == player
        default:
            return false
        }
    }
    
    var isStarted : Bool {
        get {
            switch state {
            case .Unstarted:
                return false
            default:
                return true
            }
        }
    }
    
    var isProcessing : Bool {
        get {
            switch state {
            case .Processing(let player):
                return true
            default:
                return false
            }
        }
    }
    
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

        switch state {
        case .Processing(let player):
            // get pieces' states
            var playerFlags : UInt32 = 0x0
            var isMoving : Bool = false
            
            if let scene = self.scene {
                for piece in scene.pieces {
                    if let body = piece.physicsBody {
                        playerFlags |= body.categoryBitMask
                        isMoving = (body.velocity.dx != 0) || (body.velocity.dy != 0)
                    }
                }
            }
            
            if !isMoving {
                switch playerFlags {
                case 0x01, 0x02:
                    self.win(Player.getPlayer(playerFlags))
                case 0x03:
                    self.wait(player.opponent())
                default:
                    state = .Error("playerFlags = \(playerFlags)")
                }
            }
            break
        default:
            break
        }
    }
    
    func start(gameScene : GameScene) {
        
        state = GameState.Starting
        self.scene = gameScene
        
        // first player's turn
        self.wait(PLAYER1)
    }
    
    func restart() {
        state = GameState.Starting
        
        // first player's turn
        self.wait(PLAYER1)
    }
    
    func playerDone() {
        if let player = currentPlayer {
            state = GameState.Processing(player)
        } else {
            state = GameState.Error("currentPlayer is empty")
        }
    }
    
    private func win(player : Player) {
        state = GameState.Ended(player)
        // TODO: notify scene
    }
    
    private func wait(player : Player) {
        state = GameState.Waiting(player)
        // TODO: notify scene
    }

}