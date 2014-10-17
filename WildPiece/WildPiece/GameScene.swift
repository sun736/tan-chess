//
//  GameScene.swift
//  WildPiece
//
//  Created by Amelech on 9/26/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate, LogicDelegate {
    
    var possibleBeginPt: CGPoint?
    var possibleEndPt: CGPoint?
    var possibleTouchNode :SKNode?
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // get all Piece children belongs to a player
    func piecesOfPlayer(player : Player) -> [Piece] {
        return pieces.filter{$0.player == player}
    }
    
    // MARK: SpriteKit Calls
    override func didMoveToView(view: SKView) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "applyParameters", name: "kShouldApplyParameters", object: nil)
        if(!Logic.sharedInstance.isStarted){
            self.startGame()
        }
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        for piece in self.pieces {
            if Rule.pieceIsOut(self, piece: piece) {
                piece.fadeOut()
            }
        }
        if (!Logic.sharedInstance.isEnded) {
            let (isEnd : Bool, winner : Player) = Rule.gameIsEnd(self)
            if isEnd {
                Logic.sharedInstance.win(winner)
            }
        }
        
        Logic.sharedInstance.updateState()
    }
    
    // MARK: Touch Events
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            let nodes = self.nodesAtPoint(location)
            for node in nodes as [SKNode] {
                if let piece = node as? Piece {
                    if (self.pieceShouldTap(piece) || self.pieceShouldPull(piece)) {
                        let centerPt = piece.position
                        let distance = hypotf(Float(location.x - centerPt.x),
                            Float(location.y - centerPt.y))
                        // exact distance comparison
                        if (distance <= Float(piece.radius)) {
                            
                            possibleBeginPt = location
                            possibleEndPt = nil
                            possibleTouchNode = piece
                            
                            self.pieceDidStartPull(piece)
                            break
                        }
                    }
                } else if node.name == "menuButton" {
                    
                    println("menuButton")
                    self.pauseGame()
                    var pauseScene = PauseScene(size: self.size)
                    let transition = SKTransition.crossFadeWithDuration(0.3)
                    pauseScene.scaleMode = SKSceneScaleMode.AspectFill
                    self.scene?.view?.presentScene(pauseScene, transition: transition)
                    break
                }
            }
            break
        }
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            // save end location
            possibleEndPt = location
            break
        }
        // fire
        if let actualBeginPt = possibleBeginPt {
            if let actualEndPt = possibleEndPt {
                if let piece = possibleTouchNode as? Piece{
                    let centerPt = piece.position
                    let distance = CGVectorMake(actualEndPt.x - centerPt.x, actualEndPt.y - centerPt.y)
                    // do nothing if end point lies within the node border
                    if (hypotf(Float(distance.dx), Float(distance.dy)) <= Float(piece.radius)) {
                        if self.pieceShouldTap(piece) {
                            self.pieceDidTaped(piece)
                        } else {
                            self.pieceDidCancelPull(piece)
                        }
                    } else {
                        if self.pieceShouldPull(piece) {
                            //added just for the pawn demo, delete it if needed
                            self.pieceDidPulled(piece, touchBeginPt: centerPt, touchEndPt: actualEndPt)
                            Logic.sharedInstance.playerDone()
                        } else {
                            self.pieceDidCancelPull(piece)
                        }
                    }
                }
            }
        }
        possibleBeginPt = nil
        possibleEndPt = nil
        possibleTouchNode = nil
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            // notify the node to draw a force indicator
            if let actualBeginPt = possibleBeginPt {
                if let piece = possibleTouchNode as? Piece {
                    if self.pieceShouldPull(piece) {
                        self.pieceDidChangePullDistance(piece, touchBeginPt: actualBeginPt, touchEndPt: location)
                    }
                }
            }
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        if let piece = possibleTouchNode as? Piece {
            self.pieceDidCancelPull(piece)
        }
        
        possibleBeginPt = nil
        possibleEndPt = nil
        possibleTouchNode = nil
    }

    // MARK: State Changes
    func startGame() {
        addBoard()
        addButtons()
        Rule.placePieces(self)
        Logic.sharedInstance.start(self)
    }
    
    func restartGame() {
        removePieces()
        Rule.placePieces(self)
        Logic.sharedInstance.restart()
    }
    
    func pauseGame() {
        // pause the physical world in scene
        self.paused = true
        Logic.sharedInstance.pause()
    }
    
    func unpauseGame() {
        self.paused = false
        Logic.sharedInstance.unpause()
    }
    
    func endGame() {
        self.paused = true
        Logic.sharedInstance.end()
    }
    
    // MARK: Set Up Board
    func addBoard() {
        //draw the rectange gameboard
        var yourline = SKShapeNode();
        var pathToDraw = CGPathCreateMutable();
        CGPathMoveToPoint(pathToDraw, nil, 40.0, 40.0);
        CGPathAddLineToPoint(pathToDraw, nil, 40.0, 627.0);
        CGPathAddLineToPoint(pathToDraw, nil, 335.0, 627.0);
        CGPathAddLineToPoint(pathToDraw, nil, 335.0, 40.0);
        CGPathAddLineToPoint(pathToDraw, nil, 40.0, 40.0);
        yourline.path = pathToDraw;
        yourline.strokeColor = UIColor.blueColor()
        self.addChild(yourline)

        
        //change scene background color to gray color
        scene?.backgroundColor = UIColor.lightGrayColor()
        
        // Now make the edges of the screen a physics object as well
        //scene?.physicsBody = SKPhysicsBody(edgeLoopFromRect: view.frame);
        
        scene?.physicsBody?.dynamic = false
        
        self.physicsWorld.gravity.dy = 0
        self.physicsBody?.friction = 0.9
        self.physicsWorld.contactDelegate = self
    }
    
    func addButtons() {
        //add munu button
        let menuButton = SKSpriteNode(imageNamed: "pause")
        menuButton.name = "menuButton"
        menuButton.position = CGPoint(x:CGRectGetMidX(self.frame)*1.8, y:CGRectGetMidY(self.frame)*1.94);
        self.addChild(menuButton)
    }
    
    // MARK: Add/Remove Pieces
    
    // remove all pieces
    func removePieces() {
        for piece in pieces {
            piece.removeFromParent()
        }
    }
    
    func applyParameters() {
        for piece in pieces {
            if piece.pieceType.description == WPParameterSet.sharedInstance.currentIdentifier {
                piece.physicsBody?.mass = CGFloat(WPParameterSet.sharedInstance.mass!)
                piece.physicsBody?.restitution = CGFloat(WPParameterSet.sharedInstance.restitution!)
                piece.physicsBody?.linearDamping = CGFloat(WPParameterSet.sharedInstance.damping!)
                piece.maxForce = CGFloat(WPParameterSet.sharedInstance.impulse!)
            }
        }
    }
    
    // MARK: User Operation Validators
    func pieceShouldPull(piece : Piece) -> Bool {
        return Logic.sharedInstance.isWaiting(piece.player)
    }
    
    func pieceShouldTap(piece : Piece) -> Bool {
        return !Logic.sharedInstance.isProcessing
    }
    
    // MARK: Touch Events on Pieces
    func pieceDidStartPull(piece : Piece) {
        // temporary solution to determine contacter
        CollisionController.setContacter(self, contacter: piece)
        piece.drawRing()
    }
    
    func pieceDidChangePullDistance(piece : Piece, touchBeginPt: CGPoint, touchEndPt: CGPoint) {
        let centerPt = piece.position
        let distance = CGVectorMake(touchEndPt.x - centerPt.x, touchEndPt.y - centerPt.y)
        var force = piece.forceForPullDistance(distance)
        piece.drawArrow(force)
        piece.drawDirectionHint()
    }
    
    func pieceDidCancelPull(piece : Piece) {
        piece.removeRing()
        piece.removeArrow()
        piece.removeDirectionHint()
    }
    
    func pieceDidPulled(piece : Piece, touchBeginPt: CGPoint, touchEndPt: CGPoint) {
        let centerPt = piece.position
        let distance = CGVectorMake(touchEndPt.x - centerPt.x, touchEndPt.y - centerPt.y)
        var force = piece.forceForPullDistance(distance)
        piece.physicsBody?.applyImpulse(force);

        piece.removeRing()
        piece.removeArrow()
        piece.removeDirectionHint()
    }
    
    func pieceDidTaped(piece : Piece) {
        WPParameterSet.sharedInstance.updateCurrentParameterSet(forIdentifier: piece.pieceType.description);
        piece.removeRing()
        piece.removeArrow()
        piece.removeDirectionHint()
    }
    
    // MARK: Contact Delegate
    func didBeginContact(contact: SKPhysicsContact) {
        
        CollisionController.handlContact(contact)
    }
    
    // MARK: Logic Delegate
    // get all Piece children
    var pieces : [Piece] {
        get {
            var pieces = [Piece]()
            for node in children {
                if let piece = node as? Piece {
                    pieces.append(piece)
                }
            }
            return pieces
        }
    }
    
    // player == PLAYER_NULL indicates a draw
    // update UI here
    func gameDidEnd(player : Player) {
        
    }
    
    func gameDidWait(player : Player) {
        for piece in piecesOfPlayer(player) {
            piece.flash();
        }
    }
}
