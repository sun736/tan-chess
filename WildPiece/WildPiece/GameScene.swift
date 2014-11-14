//
//  GameScene.swift
//  WildPiece
//
//  Created by Amelech on 9/26/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import SpriteKit

protocol GameSceneDelegate: class {
    func sendDataToPeer(piece: CGPoint, force: CGVector)
    func endMCSession()
}

class GameScene: SKScene, SKPhysicsContactDelegate, UIGestureRecognizerDelegate, LogicDelegate {
    
    var pullBeginPoint: CGPoint?
    var pullEndPoint: CGPoint?
    var touchNode :SKNode?
    var currentPiece : Piece?
    var moveableSet = Array<Piece>()
    var lastMove : (piece : Piece?, step : Int) = (nil, 0)
    var board: Board?
    var top : SKSpriteNode?
    var bottom :SKSpriteNode?
    var soundPlayer: Sound?
    var pieceLayer : SKNode?
    var boardLayer : SKNode?
    var worldLayer : SKNode?
    var pullForce: CGVector?
    var trajactoryTimer: NSTimer?
    
    var skillPanel: SkillPanel?
    
    var sceneDelegate: GameSceneDelegate?
    
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
            self.soundPlayer = Sound()
            self.startGame()
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        for piece in self.pieces {
            if Rule.pieceIsOut(self, piece: piece) {
                if piece.isFading == false
                {
                    piece.isFading = true
                    println("fadeOut at GameScene")
                  
                    if piece.player.id != Logic.sharedInstance.currentPlayer?.id
                    {
                        self.board?.increaseSkill(piece.player.opponent())
                    }
                    piece.fadeOut()
                }
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
            let location = touch.locationInNode(self.pieceLayer)
            let nodes = self.pieceLayer?.nodesAtPoint(location)
            for node in nodes as [SKNode] {
                
                if let piece = node as? Piece {
                    if (self.pieceShouldTap(piece) || self.pieceShouldPull(piece)) {
                        let centerPt = piece.position
                        let distance = hypotf(Float(location.x - centerPt.x),
                            Float(location.y - centerPt.y))
                        
                        if Logic.sharedInstance.isWaiting(piece.player) {
                            Rule.touchDown(self, piece: piece)
                        }
                        // exact distance comparison
                        if (distance <= Float(piece.radius)) {
                            
                            pullBeginPoint = location
                            pullEndPoint = nil
                            touchNode = piece
                            
                            self.pullBegan(piece)
                            break
                        }
                      
                    }
                }

            }
            break
            
            
        }
        
        //detect the skill panel touch
        let location = touches.anyObject()?.locationInNode(self.skillPanel)
        let touchedNode = self.skillPanel?.nodeAtPoint(location!)
        
        if touchedNode?.name == "Shield"
        {
            var player = currentPiece?.player
            if self.board?.skillController.getCD(player!) == 3
            {
                currentPiece?.drawShield()
                self.board?.resetSkillBar(player!)
            }
        }else if touchedNode?.name == "Force"
        {
            var player = currentPiece?.player
            if self.board?.skillController.getCD(player!) == 3
            {
                println("force")
                currentPiece?.isPowered = true
                
                //currentPiece?.runAction(SKAction.sequence([SKAction.waitForDuration(0.3), SKAction.resizeToWidth(60,height:60,duration:0.3),SKAction.resizeToWidth(40,height:40,duration:0.3)]))
                currentPiece?.drawPowerRing()
                self.board?.resetSkillBar(player!)
                
            }
        }else if touchedNode?.name == "Aim"
        {
            var player = currentPiece?.player
            if self.board?.skillController.getCD(player!) == 3
            {
                currentPiece?.shouldDrawTrajectory = true
                self.board?.resetSkillBar(player!)
            }
        }
        /*if touchedNode?.name == "skillPanel"
        {
            self.skillPanel?.hideSkill()
            currentPiece?.zPosition = 1
            currentPiece = nil
        }*/
        self.skillPanel?.hideSkill()
        currentPiece?.zPosition = 1
        currentPiece = nil
        

       
    }
    
    override func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        var doubleTap : Bool = false
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self.pieceLayer)
            // save end location
            pullEndPoint = location
            doubleTap = touch.tapCount == 2
            break
        }
        // fire
        if let pullBeginPoint = pullBeginPoint {
            if let pullEndPoint = pullEndPoint {
                if let piece = touchNode as? Piece{
                    let centerPt = piece.position
                    
                    let distance = CGVectorMake(pullEndPoint.x - centerPt.x, pullEndPoint.y - centerPt.y)
                    let rawForce = piece.forceForPullDistance(distance)
                    let force = redirectForce(piece, force: rawForce)
                    
                    // do nothing if end point lies within the node border
                    if Logic.sharedInstance.isWaiting(piece.player) {
                        Rule.touchUp(self, piece: piece)
                    }
                    if (hypotf(Float(force.dx), Float(force.dy)) <= Float(piece.minForce)) {
                        self.pullCancelled(piece)
                        if self.pieceShouldTap(piece) {
                            self.pieceDidTaped(piece, doubleTap : doubleTap)
                        }
                    } else {
                        if self.pieceShouldPull(piece) {
                            if Logic.sharedInstance.onlineMode {
                                self.sceneDelegate?.sendDataToPeer(piece.position, force: force)
                            }
                            self.pullEnded(piece, force: force)
                            Logic.sharedInstance.playerDone()
                            self.board?.TurnDone()
                        } else {
                            self.pullCancelled(piece)
                        }
                    }
                }
            }
        }
        pullBeginPoint = nil
        pullEndPoint = nil
        touchNode = nil
    }
    
    override func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self.pieceLayer)
            // notify the node to draw a force indicator
            if let pullBeginPoint = pullBeginPoint {
                if let piece = touchNode as? Piece {
                    if self.pieceShouldPull(piece) {
                        let centerPt = piece.position
                        let distance = CGVectorMake(location.x - centerPt.x, location.y - centerPt.y)
                        let rawForce = piece.forceForPullDistance(distance)
                        let force = redirectForce(piece, force: rawForce)
                        self.pullMoved(piece, force: force)
                    }
                }
            }
        }
    }
    
    override func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        if let piece = touchNode as? Piece {
            if Logic.sharedInstance.isWaiting(piece.player) {
                Rule.touchUp(self, piece: piece)
            }
            self.pullCancelled(piece)
        }
        
        pullBeginPoint = nil
        pullEndPoint = nil
        touchNode = nil
    }
    
    
    //MARK: Pinch Gesture
    func handlePinch(recognizer: UIPinchGestureRecognizer) {
        //println("pinch")
        if recognizer.state == UIGestureRecognizerState.Ended{
            println("show pause menu")
           
            
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
        addLayers()
//        self.soundPlayer?.playBackgroundMusic()
        addBoard()
        //addButtons()
        Rule.placePieces(self)
        Logic.sharedInstance.start(self)
        updateMoveableSet()
    }
    
    func restartGame() {
        removePieces()
        Rule.placePieces(self)
        self.board?.resetSkillBar(PLAYER1)
        self.board?.resetSkillBar(PLAYER2)
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
//        self.soundPlayer?.stopBackgroundMusic();
        self.paused = true
        Logic.sharedInstance.whoami = PLAYER_NULL
        Logic.sharedInstance.onlineMode = false
        Logic.sharedInstance.end()
        sceneDelegate?.endMCSession()
    }
    
    func updateLastMove(piece : Piece) {
        if lastMove.piece === piece {
            lastMove.step++
        } else {
            lastMove = (piece, 1)
        }
    }
    
    // MARK: Set Up Layers
    func addLayers() {
        var newWorldLayer = SKNode()
        newWorldLayer.zPosition = 0
        if worldIsRotated {
            newWorldLayer.zRotation = CGFloat(M_PI)
            newWorldLayer.position = CGPointMake(self.frame.size.width, self.frame.size.height)
        }
        addChild(newWorldLayer)
        self.worldLayer = newWorldLayer
        
        var newBoardLayer = SKNode()
        newBoardLayer.zPosition = 0
        newWorldLayer.addChild(newBoardLayer)
        self.boardLayer = newBoardLayer

        var newPieceLayer = SKNode()
        newPieceLayer.zPosition = 1;
        newWorldLayer.addChild(newPieceLayer)
        self.pieceLayer = newPieceLayer
    }
    
    // MARK: Set Up Board
    func addBoard() {
        
        let board = Board(width: self.frame.width, length: self.frame.height, marginY : 40.0)
        self.board = board
        self.boardLayer?.addChild(board)
        
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
    
    var worldIsRotated : Bool {
        return !Logic.sharedInstance.isAtHome
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
        
        if Logic.sharedInstance.onlineMode {
            return (Logic.sharedInstance.whoami == piece.player) && (moveableSet.filter{$0 === piece}.count > 0)
        } else {
            return moveableSet.filter{$0 === piece}.count > 0
        }
    }
    
    func pieceShouldTap(piece : Piece) -> Bool {
        return !Logic.sharedInstance.isProcessing
    }
    
    // MARK: Pull on Pieces
    func pullBegan(piece : Piece) {
        // temporary solution to determine contacter
        //CollisionController.setContacter(self, contacter: piece)
        piece.drawRing()
        if piece is PieceCanon {
            piece.fadeTo()
        }
        trajactoryTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("drawTrajactory:"), userInfo: piece, repeats: true)
    }
    
    func pullMoved(piece : Piece, var force: CGVector) {
//        println("changed force: \(force.dx), \(force.dy)")
        piece.drawArrow(force)
        piece.drawDirectionHint()
        pullForce = force
        //piece.drawTrajectory(force)
    }
    
    func pullCancelled(piece : Piece) {
        piece.removeRing()
        piece.removeArrow()
        piece.removeDirectionHint()
        piece.cancelFade()
        piece.removeTrajectory()
        pullForce = nil
        trajactoryTimer?.invalidate()
    }
    
    func pullEnded(piece : Piece, var force: CGVector) {
//        println("shooting force: \(force.dx), \(force.dy)")
        //MARK set canon to not collisionable
        if piece is PieceCanon {
            piece.physicsBody?.categoryBitMask = Piece.BITMASK_TRANS()
            piece.physicsBody?.collisionBitMask = Board.BITMASK_BOARD()
            piece.physicsBody?.contactTestBitMask = Piece.BITMASK_RED() | Piece.BITMASK_BLUE()
            //print("find a canon\n")
            //print("\(piece.physicsBody?.categoryBitMask)\n")
            //print("\(piece.physicsBody?.collisionBitMask)\n")
        }
        // if this is the place to set contacter, knight can only achieve kill-move by itself, no team work
        CollisionController.setContacter(self, contacter: piece)
        applyImpulseToWorldObject(piece, force : force)
        updateLastMove(piece)
        
        piece.removeRing()
        piece.removeArrow()
        piece.removeDirectionHint()
        piece.removeTrajectory()
        piece.removeSkill()
        piece.removePowerRing()
        pullForce = nil
        trajactoryTimer?.invalidate()
    }
    
    // MARK: Tap on Pieces
    func pieceDidTaped(piece : Piece, doubleTap : Bool) {
//        println("doubleTap: \(doubleTap)")
        if !shouldShowSkill(piece)
        {
            return
        }
        
        if doubleTap {
            if piece != currentPiece
            {
                //currentPiece?.hideSkill()
                //piece.showSkill()
                currentPiece = piece
                self.showSkill()
                
            }
            //piece.hideSkill()
        } else {
            WPParameterSet.sharedInstance.updateCurrentParameterSet(forIdentifier: piece.pieceType.description);
        }
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
            if let pieceLayer = self.pieceLayer {
                for node in pieceLayer.children {
                    if let piece = node as? Piece {
                        pieces.append(piece)
                    }
                }
            }
            return pieces
        }
    }
    
    var piecesOfCurrentUser : [Piece] {
        get {
            var pieces = [Piece]()
            if let pieceLayer = self.pieceLayer {
                for node in pieceLayer.children {
                    if let piece = node as? Piece {
                        if Logic.sharedInstance.isWaiting(piece.player) {
                            pieces.append(piece)
                        }
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
        if (pieces.filter{$0 === self.lastMove.piece}).count == 0 {
            return true
        }

        var (turnChange, pieceChange) = Rule.gameShouldChangeTurn(self, lastMove: lastMove)
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
        //stop play music
//        self.soundPlayer?.stopBackgroundMusic()
        
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
                piece.cancelFade()
            }
        }
        //player.canKill = true;
    }

    func gameDidProcess(player : Player) {
            moveableSet = []
    }


    // MARK: Rotation
    func opponentLocation(location : CGPoint) -> CGPoint {
        return CGPointMake(size.width - location.x, size.height - location.y)
    }
    
    func rotateVector(vector : CGVector) -> CGVector {
        return CGVectorMake(-vector.dx, -vector.dy)
    }
    
    func redirectForce(piece : Piece, var force : CGVector) -> CGVector {
        return Rule.pieceValidForce(self, piece: piece, force: force)
    }
    
    func applyImpulseToWorldObject(piece : SKNode, var force: CGVector) {
        if worldIsRotated {
            force = self.rotateVector(force)
        }
        piece.physicsBody?.applyImpulse(force);
    }
    
    // Mark: piece effect
    func drawTrajactory(timer : NSTimer) {
        if let piece = timer.userInfo as? Piece{
            if let pullForce = pullForce {
                piece.drawTrajectory()
                if let trajectoryNode = piece.trajectory {
                    applyImpulseToWorldObject(trajectoryNode, force : pullForce)
                }
            }
        }
    }
    
    //MARK:show skill bar
    func showSkill()
    {
        self.skillPanel = SkillPanel(player: (currentPiece?.player)!)
        self.skillPanel?.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame))
        currentPiece?.zPosition = 5
        self.addChild(self.skillPanel!)
        
    }
    
    func shouldShowSkill(piece: Piece) -> Bool{
        return self.moveableSet[0].player.id == piece.player.id
    }
}
