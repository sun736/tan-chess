//
//  GameScene.swift
//  WildPiece
//
//  Created by Amelech on 9/26/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    
    let MIN_MOVEMENT_DISTANCE = 50.0
    var possibleBeginPt: CGPoint?
    var possibleEndPt: CGPoint?
    var possibleTouchNode :SKNode?
    var gameStart = false;
    
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

    // get all Piece children belongs to a player
    func piecesOfPlayer(player : Player) -> [Piece] {
        return pieces.filter{$0.player == player}
    }
    
    override func didMoveToView(view: SKView) {
        if(!Logic.sharedInstance.isStarted){
            self.startGame()
        }
    }
    
    // init methods
    func startGame() {
        configureBoard()
        configureButtons()
        placePieces()
        Logic.sharedInstance.start(self)
    }
    
    func restartGame() {
        removePieces()
        placePieces()
        Logic.sharedInstance.restart()
    }
    
    func configureBoard() {
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
        println("Move game scene to view")
        
        //change scene background color to gray color
        scene?.backgroundColor = UIColor.lightGrayColor()
        
        // Now make the edges of the screen a physics object as well
        //scene?.physicsBody = SKPhysicsBody(edgeLoopFromRect: view.frame);
        
        scene?.physicsBody?.dynamic = false
        
        self.physicsWorld.gravity.dy = 0
        self.physicsBody?.friction = 0.9
        self.physicsWorld.contactDelegate = self
    }
    
    func configureButtons() {
        //add munu button
        let menuButton = SKSpriteNode(imageNamed: "menuButton")
        menuButton.name = "menuButton"
        menuButton.position = CGPoint(x:CGRectGetMidX(self.frame)*1.7, y:CGRectGetMidY(self.frame)*1.90);
        self.addChild(menuButton)
    }
    
    // Contact delegate methods
    func didBeginContact(contact: SKPhysicsContact) {
        
        CollisionController.handlContact(contact)
    }
    
    // Touch events
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
    
    // game logic
    func pieceShouldPull(piece : Piece) -> Bool {
        return Logic.sharedInstance.isWaiting(piece.player)
    }
    
    func pieceShouldTap(piece : Piece) -> Bool {
        return !Logic.sharedInstance.isProcessing
    }
    
    // called each frame
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        var pieces = scene?.children
        var piece: AnyObject
        
        for node in pieces as [SKNode] {
            if node.name == "piece" {
                let piece = node as Piece
                //println("x:\(piece.position.x), y:\(piece.position.y)")
                if piece.position.x < 40 || piece.position.x > 335 {
                    piece.fadeOut()
                }
                if piece.position.y < 40 || piece.position.y > 627 {
                    piece.fadeOut()
                }
                
            }
        }
        
        Logic.sharedInstance.updateState()
    }
    
    // methods deal with touches on piece
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
    }
    
    func pieceDidCancelPull(piece : Piece) {
        piece.removeRing()
        piece.removeArrow()
    }
    
    func pieceDidPulled(piece : Piece, touchBeginPt: CGPoint, touchEndPt: CGPoint) {
        let centerPt = piece.position
        let distance = CGVectorMake(touchEndPt.x - centerPt.x, touchEndPt.y - centerPt.y)
        var force = piece.forceForPullDistance(distance)
        piece.physicsBody?.applyImpulse(force);
        
        piece.removeRing()
        piece.removeArrow()
    }
    
    func pieceDidTaped(piece : Piece) {
        piece.removeRing()
        piece.removeArrow()
    }
    
    // functions to add pieces
    
    func addPiece(pieceType : PieceType, location : CGPoint, player : Player) {
        // println("location: \(location)")
        var piece = Piece.newPiece(pieceType, player: player);
        piece.position = location
        self.addChild(piece)
    }
    
    // add a piece for each player, with symmetrical position
    func addPairPieces(pieceType : PieceType, location : CGPoint) {
        addPiece(pieceType, location: location, player: PLAYER1)
        let opponentLocation = CGPointMake(self.size.width - location.x, self.size.height - location.y)
        addPiece(pieceType, location: opponentLocation, player: PLAYER2)
    }
    
    func placePieces() {
        
        //Just for demo purpose
        // add kings
        addPairPieces(PieceType.King, location: CGPointMake(187, 100))
        // add pawns
        addPairPieces(PieceType.Pawn, location: CGPointMake(107, 220))
        addPairPieces(PieceType.Pawn, location: CGPointMake(267, 220))
        addPairPieces(PieceType.Pawn, location: CGPointMake(187, 220))
        // add elephants
        addPairPieces(PieceType.Elephant, location: CGPointMake(150, 160))
        addPairPieces(PieceType.Elephant, location: CGPointMake(224, 160))
    }
    
    func removePieces() {
        for piece in pieces {
            piece.removeFromParent()
        }
    }
}
