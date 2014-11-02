//
//  GameScene.swift
//  WildPiece
//
//  Created by Amelech on 9/26/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate, LogicDelegate {
    
    var possibleBeginPt: CGPoint?
    var possibleEndPt: CGPoint?
    var possibleTouchNode :SKNode?
    var moveableSet = Array<Piece>()
    var lastMove : (piece : Piece?, step : Int) = (nil, 0)
    var board: Board?
    var top : SKSpriteNode?
    var bottom :SKSpriteNode?
    
    
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
            
            let pinchGesture = UIPinchGestureRecognizer(target: self, action: Selector("handlePinch:"))
            pinchGesture.delegate = self
            self.view?.addGestureRecognizer(pinchGesture)
            top?.runAction(SKAction.moveToY(CGFloat(850), duration: 0.4))
            bottom?.runAction(SKAction.moveToY(CGFloat(-180), duration: 0.4))
            self.startGame()
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        for piece in self.pieces {
            if Rule.pieceIsOut(self, piece: piece) {
                println("fadeOut at GameScene")
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
                    let force: CGVector = CGVectorMake(centerPt.x - actualEndPt.x, centerPt.y - actualEndPt.y)
                    let reforce: CGVector = Rule.pieceValidForce(self, piece: piece, force: force)
                    let distance = CGVectorMake(-reforce.dx, -reforce.dy)
                    // do nothing if end point lies within the node border
                    if (hypotf(Float(distance.dx), Float(distance.dy)) <= Float(piece.radius)) {
                        if self.pieceShouldTap(piece) {
                            self.pieceDidTaped(piece)
                        } else {
                            self.pieceDidCancelPull(piece)
                        }
                    } else {
                        if self.pieceShouldPull(piece) {
                            self.pieceDidPulled(piece, distance: distance)
                            Logic.sharedInstance.playerDone()
                            self.board?.TurnDone()
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
                        let centerPt = piece.position
                        let force: CGVector = CGVectorMake(centerPt.x - location.x, centerPt.y - location.y)
                        let reforce: CGVector = Rule.pieceValidForce(self, piece: piece, force: force)
                        let distance = CGVectorMake(-reforce.dx, -reforce.dy)
                        
                        self.pieceDidChangePullDistance(piece, distance: distance)
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
    
    
    //MARK: Pinch Gesture
    func handlePinch(recognizer: UIPinchGestureRecognizer) {
        //println("pinch")
        if recognizer.state == UIGestureRecognizerState.Ended{
            println("menuButton")
           
            
            //Get the snapshot of the screen
            var size : CGSize! = self.view?.frame.size
            var bounds : CGRect! = self.view?.bounds
            if size != nil{
                self.pauseGame()
                var pauseScene = PauseScene(size: self.size)
                pauseScene.scaleMode = SKSceneScaleMode.AspectFill
                UIGraphicsBeginImageContext(size)
                self.view?.drawViewHierarchyInRect(bounds, afterScreenUpdates: true)
                var snapshot = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                //cut the snapshot with top and bottom half
                var topBounds = CGRectMake(bounds.origin.x, bounds.origin.y, bounds.width, bounds.height/2)
                var backgroundTop = CGImageCreateWithImageInRect(snapshot.CGImage, topBounds)
                
                var bottomBounds = CGRectMake(bounds.origin.x, bounds.origin.y + bounds.height/2, bounds.width, bounds.height/2)
                var backgroundBottom = CGImageCreateWithImageInRect(snapshot.CGImage, bottomBounds)
                
                pauseScene.setTopAndBottomImage(UIImage(CGImage: backgroundTop)!,bottom:UIImage(CGImage: backgroundBottom)!)
                
                self.scene?.view?.presentScene(pauseScene)
            }
        }
    }



    // MARK: State Changes
    func startGame() {
        addBoard()
        //addButtons()
        Rule.placePieces(self)
        Logic.sharedInstance.start(self)
        updateMoveableSet()
    }
    
    func restartGame() {
        removePieces()
        Rule.placePieces(self)
        Logic.sharedInstance.restart()
        updateMoveableSet()
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
    
    func updateLastMove(piece : Piece) {
        if lastMove.piece === piece {
            lastMove.step++
        } else {
            lastMove = (piece, 1)
        }
    }
    
    // MARK: Set Up Board
    func addBoard() {
        
        let board = Board(width: self.frame.width, length: self.frame.height, marginY : 40.0)
        self.board = board
        self.addChild(board)
        
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
        //self.addChild(menuButton)
    }
    
    func setTopAndBottomImage(top: UIImage, bottom: UIImage)
    {
        self.top = SKSpriteNode(texture: SKTexture(image: top))
        self.top?.size = CGSizeMake(self.frame.size.width, self.frame.size.height/2)
        self.top?.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.5);
        self.top?.zPosition = 10.0
        self.addChild(self.top!)
        
        self.bottom = SKSpriteNode(texture: SKTexture(image: bottom))
        self.bottom?.size = CGSizeMake(self.frame.size.width, self.frame.size.height/2)
        self.bottom?.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*0.5);
        self.bottom?.zPosition = 10.0
        self.addChild(self.bottom!)
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
                piece.maxForceLevel = CGFloat(WPParameterSet.sharedInstance.impulse!)
            }
        }
    }
    
    // MARK: User Operation Validators
    func pieceShouldPull(piece : Piece) -> Bool {
        return moveableSet.filter{$0 === piece}.count > 0
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
    
    func pieceDidChangePullDistance(piece : Piece, distance: CGVector) {
        var force = piece.forceForPullDistance(distance)
        piece.drawArrow(force)
        piece.drawDirectionHint()
    }
    
    func pieceDidCancelPull(piece : Piece) {
        piece.removeRing()
        piece.removeArrow()
        piece.removeDirectionHint()
    }
    
    func pieceDidPulled(piece : Piece, distance: CGVector) {
        var force = piece.forceForPullDistance(distance)
        
        //MARK set canon to not collisionable
        if piece is PieceCanon {
            piece.physicsBody?.categoryBitMask = Piece.BITMASK_TRANS()
            piece.physicsBody?.collisionBitMask = Board.BITMASK_BOARD()
            piece.physicsBody?.contactTestBitMask = Piece.BITMASK_RED() | Piece.BITMASK_BLUE()
            //print("find a canon\n")
            //print("\(piece.physicsBody?.categoryBitMask)\n")
            //print("\(piece.physicsBody?.collisionBitMask)\n")
        }
        
        piece.physicsBody?.applyImpulse(force);
        updateLastMove(piece)

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
        //print("herereerererer contact\n")
        CollisionController.handlContact(self, contact: contact)
    }
    
    func didEndContact(contact: SKPhysicsContact) {
        //print("herereerererer contact ended\n")
        //CollisionController.handleEndContact(contact)
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
    
    var piecesOfCurrentUser : [Piece] {
        get {
            var pieces = [Piece]()
            for node in children {
                if let piece = node as? Piece {
                    if Logic.sharedInstance.isWaiting(piece.player) {
                        pieces.append(piece)
                    }
                }
            }
            return pieces
        }
    }
    
    func updateMoveableSet () {
        moveableSet.removeAll()
        moveableSet += piecesOfCurrentUser
    }
    
    func gameShouldChangeTurn() -> Bool {
        var array = children.filter{$0 === self.lastMove.piece}
        if array.count == 0 {
            return true
        }

        var (turnChange, pieceChange) = Rule.gameShouldChangeTurn(lastMove)
        if !turnChange && !pieceChange {
            if let piece = lastMove.piece {
                moveableSet = [piece]
            }
        }
        return turnChange
    }
    
    // player == PLAYER_NULL indicates a draw
    // update UI here
    func gameDidEnd(player : Player) {
        var endScene = EndScene(size: self.size)
        let winner = SKLabelNode(fontNamed:"Verdana")
        if(player.id == 1){
            winner.text = "Blue Wins!"
            endScene.backgroundColor = UIColor.UIColorFromRGB(0x96d4fb, alpha: 1)
        }else{
            winner.text = "Red Wins!"
            endScene.backgroundColor = UIColor.UIColorFromRGB(0xfb8888, alpha: 1)
        }
        winner.fontSize = 35
        winner.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame)*1.6)
        endScene.addChild(winner)
        let transition = SKTransition.crossFadeWithDuration(0.3)
        endScene.scaleMode = SKSceneScaleMode.AspectFill
        self.scene?.view?.presentScene(endScene, transition: transition)
    }
    
    func gameDidWait(player : Player) {
        // redraw the board with new color
        if let board = self.board {
            var isUpTurn = player.id != 1
            board.setTurn(isUpTurn)
        }
        
        if let piece = lastMove.piece {
            if piece.player !== player {
                updateMoveableSet()
            }
        }

//        for piece in moveableSet {
//            piece.flash();
//        }
        
        // Canon made a original move, need to reset its mask manually
        for piece in self.piecesOfPlayer(player.opponent()) {
            if piece is PieceCanon {
                piece.physicsBody?.categoryBitMask = player.opponent().bitMask
                piece.physicsBody?.collisionBitMask = Piece.BITMASK_BLUE() | Piece.BITMASK_RED() | Board.BITMASK_BOARD()
                piece.physicsBody?.contactTestBitMask = Piece.BITMASK_RED() | Piece.BITMASK_BLUE() | Piece.BITMASK_TRANS()
            }
        }
        //player.canKill = true;
    }

    func gameDidProcess(player : Player) {
            moveableSet = []
    }
}
