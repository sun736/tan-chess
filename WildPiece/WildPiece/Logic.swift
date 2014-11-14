//
//  Logic.swift
//  WildPiece
//
//  Created by Kaiqi on 14-10-3.
//  Copyright (c) 2014年 Project TC. All rights reserved.
//

import Foundation
import SpriteKit

// MARK: Logic Delegate
protocol LogicDelegate : class {
    
    func gameDidEnd(player : Player)
    func gameDidWait(player : Player)
    func gameDidProcess(player : Player)
    func gameShouldChangeTurn() -> Bool
    var pieces : [Piece] { get }
}

// MARK: Logic class

let SPEED_LOWER_BOUND : Float = 4.0

class Logic {
    
    enum GameState : Printable {
        case Unstarted
        case Starting
        case Paused
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
            case .Paused:
                return "Paused"
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
    
    private weak var scene: LogicDelegate?
    
    private var state: GameState {
        didSet {
            println("state: \(state)")
        }
    }
    
    var onlineMode: Bool = false
    
    var whoami: Player = PLAYER_NULL
    
    private var oldState: GameState?
    
    func isWaiting(player: Player) -> Bool {
        switch state {
        case .Waiting(let waitingPlayer):
            return waitingPlayer == player
        default:
            return false
        }
    }
    
    var isStarted : Bool {
//        println(state)
        switch state {
        case .Unstarted:
            return false
        default:
            return true
        }
    }
    
    var isProcessing : Bool {
        switch state {
        case .Processing(let player):
            return true
        default:
            return false
        }
    }
    
    var isEnded : Bool {
        switch state {
        case .Ended(let player):
            return true
        default:
            return false
        }
    }
    
    var isAtHome : Bool {
//        println("\(onlineMode), \(whoami)")
        return !onlineMode || whoami == PLAYER1
    }
    
    init() {
        state = .Unstarted
        onlineMode = false;
    }
    
    class var sharedInstance : Logic {
        struct Static {
            static let instance : Logic = Logic()
        }
        return Static.instance
    }
    
    func updateState() {

        switch state {
        case .Processing(let player):
            // get pieces' states
//            var playerFlags : UInt32 = 0x0
            var isMoving : Bool = false
            
            if let scene = self.scene {
                for piece in scene.pieces {
                    if let body = piece.physicsBody {
                        let v = hypotf(Float(body.velocity.dx), Float(body.velocity.dy))
//                        if (v > 0) {
//                            println(Int(v))
//                        }
                        if v < SPEED_LOWER_BOUND {
                            body.velocity.dx = 0
                            body.velocity.dy = 0
                        }
                        isMoving |= (body.velocity.dx != 0) || (body.velocity.dy != 0)
                    }
                }
            }
            
            if !isMoving {
                if let scene = self.scene {
                    if scene.gameShouldChangeTurn() {
                        self.wait(player.opponent())
                    } else {
                        self.wait(player)
                    }
                }
                
//                switch playerFlags {
//                case 0x00, 0x01, 0x02:
//                    self.win(Player.getPlayer(playerFlags))
//                case 0x03:
//                    self.wait(player.opponent())
//                default:
//                    state = .Error("playerFlags = \(playerFlags)")
//                }
            }
        default:
            break
        }
    }
    
    func start(gameScene : LogicDelegate) {
        switch state {
        case .Unstarted:
            state = GameState.Starting
            self.scene = gameScene
            
            // first player's turn
            self.wait(PLAYER1)
            break
        default:
            state = GameState.Error("start game in wrong state: \(state)")
        }
    }
    
    func restart() {
        state = GameState.Starting
        
        // first player's turn
        self.wait(PLAYER1)
    }
    
    func pause() {
        oldState = state
        state = GameState.Paused
    }
    
    func unpause() {
        switch state {
        case .Paused:
            if let newstate = oldState {
                state = newstate
                oldState = nil
            } else {
                state = GameState.Error("unpause without old state")
            }
        default:
            state = GameState.Error("unpause in wrong state: \(state)")
        }
    }
    
    func playerDone() {
        switch state {
        case .Waiting(let player):
            state = GameState.Processing(player)
            self.scene?.gameDidProcess(player)
        default:
            state = GameState.Error("player done in wrong state: \(state)")
        }
    }
    
    func end() {
        scene = nil
        state = GameState.Unstarted
    }
    
    func win(player : Player) {
        state = GameState.Ended(player)
        // notify scene
        scene?.gameDidEnd(player)
    }
    
    private func wait(player : Player) {
        state = GameState.Waiting(player)
        // notify scene
        scene?.gameDidWait(player)
    }

    func getGameState() -> GameState {
        return state
    }
}