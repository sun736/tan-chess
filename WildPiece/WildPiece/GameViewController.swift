//
//  GameViewController.swift
//  WildPiece
//
//  Created by Amelech on 9/26/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import UIKit
import SpriteKit
import MultipeerConnectivity

let kShouldPresentMenuSceneNotification = "kShouldPresentMenuSceneNotification"
let kShouldPresentTutorialNotification = "kShouldPresentTutorialNotification"

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData!)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, MCBrowserViewControllerDelegate, MenuSceneDelegate, HelpSceneDelegate, GameSceneDelegate{
    
    @IBOutlet weak var toolBarContainerView: UIView!
    @IBOutlet weak var switchControl: UISwitch!
    
    var appDelegate  : AppDelegate!
    var menuScene : MenuScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        
        appDelegate.gameScene?.sceneDelegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentMenuScene:",
            name: kShouldPresentMenuSceneNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "shouldDisplayTutorial", name:kShouldPresentTutorialNotification, object: nil);

        if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
            let skView = self.view as SKView
            skView.showsFPS = true
            skView.showsNodeCount = true
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            /* Set single touch */
            skView.multipleTouchEnabled = false;
            
            //init the gamescene in AppDelegata
            
            menuScene = MenuScene(size: scene.size)
            menuScene?.menuDelegate = self
            skView.presentScene(menuScene)
        }
        
        self.switchControl.on = false
        self.toolBarContainerView.alpha = 0.0
        
        WPParameterSet.sharedInstance.updateCurrentParameterSet(forIdentifier: "King")
        
        // multipeer connectivity
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedData:", name: "MC_DidReceiveDataNotification", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleStateChange:", name: "MC_DidChangeStateNotification", object: nil)
        
        var userDefaults = NSUserDefaults.standardUserDefaults()
        if userDefaults.valueForKey("audioOn") == nil
        {
            userDefaults.setValue(true, forKey: "musicOn")
            userDefaults.setValue(true, forKey: "audioOn")
            userDefaults.setValue(true, forKey: "aimOn")
            userDefaults.synchronize()
        }
    }
    
    func advertiseBluetooth() {
        self.appDelegate.mcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        self.appDelegate.mcHandler.setupSession()
        self.appDelegate.mcHandler.advertiseSelf(true)
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        // send its peerid to the other device
        // tell the other device to dismiss browser
        self.shakeHandWithPeer()
        appDelegate.mcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func browserViewControllerWasCancelled(browserViewController: MCBrowserViewController!) {
        appDelegate.mcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func presentMenuScene(notification : NSNotification) {
        var scene = notification.object as? SKScene
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var gameScene = appDelegate.gameScene
        gameScene?.endGame()
        let transition = SKTransition.crossFadeWithDuration(0.3)
        scene?.view?.presentScene(menuScene, transition: transition)
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction func switchToolBar(sender: AnyObject) {
        var targetAlpha = switchControl.on ? 1.0 : 0.0
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.toolBarContainerView.alpha = CGFloat(targetAlpha)
        })
        NSNotificationCenter.defaultCenter().postNotificationName("kUpdateToolBar", object: nil)
    }
    
    @IBAction func connectWithPlayer(sender: AnyObject?) {
        if appDelegate.mcHandler.session != nil {
            appDelegate.mcHandler.setupBrowser()
            appDelegate.mcHandler.browser.delegate = self
            
            self.presentViewController(appDelegate.mcHandler.browser, animated: true, completion: nil)
        }
    }
    
    func shakeHandWithPeer() {
        let messageDict = ["shakeHands": ["UDID": appDelegate.mcHandler.UDID]]
        
        sendMessageDict(messageDict)
    }
    
    func sendDataToPeer(position: CGPoint, force: CGVector) {
        let messageDict = ["applyForce": ["position": ["x": position.x, "y": position.y], "force" : ["dx": force.dx, "dy": force.dy]]]
        
        sendMessageDict(messageDict)
    }
    
    func sendSkillToPeer(piece: Piece, skillName: String!) {
        let messageDict = ["applySkill": ["pieceName": piece.name, "skillName": skillName]]
        
        sendMessageDict(messageDict)
    }
    
    private func sendMessageDict(messageDict: AnyObject) {
        let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        
        var error:NSError?
        
        appDelegate.mcHandler.session.sendData(messageData, toPeers: appDelegate.mcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }
    }
    
    func updateAllPiecePosition(pieces: [Piece]) {
        var positionDict = [String:AnyObject]()
        
        for piece in pieces {
            let data = ["living": piece.living, "position": ["x": piece.position.x, "y": piece.position.y]]
            positionDict.updateValue(data, forKey: piece.name!)
        }
        
        let messageDict = ["updatePositions": positionDict]
        
        let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        
        var error:NSError?
        
        appDelegate.mcHandler.session.sendData(messageData, toPeers: appDelegate.mcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }
    }
    
    func handleReceivedData(notification: NSNotification){
        if !Logic.sharedInstance.onlineMode {
            return
        }
        let userInfo = notification.userInfo! as Dictionary
        let receivedData:NSData = userInfo["data"] as NSData
        
        let message: NSDictionary = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary

        if let action = message["applyForce"] as? NSDictionary {
            let position = action["position"] as NSDictionary
            let force = action["force"] as NSDictionary
            let gameScene: GameScene? = self.appDelegate.gameScene
            
            let nodes = gameScene?.pieceLayer?.nodesAtPoint(CGPointMake(CGFloat(position["x"] as Float), CGFloat(position["y"] as Float)))
            for node in nodes as [SKNode] {
                if let piece = node as? Piece {
                    gameScene?.pullEnded(piece, force: CGVectorMake(force["dx"] as CGFloat, force["dy"]  as CGFloat))
                    Logic.sharedInstance.playerDone()
                    break
                }
            }
        } else if let action = message["shakeHands"] as? NSDictionary {
            // set player side
            if Logic.sharedInstance.whoami == PLAYER_NULL {
                let peerID: MCPeerID = userInfo["peerID"] as MCPeerID
                let selfID: MCPeerID = appDelegate.mcHandler.peerID
                let peerUDID: String = action["UDID"] as String
                let selfUDID: String = appDelegate.mcHandler.UDID
                println("\(selfID.displayName) - \(selfUDID) vs \(peerID.displayName) - \(peerUDID)")
                if selfUDID < peerUDID {
                    Logic.sharedInstance.whoami = PLAYER1
                } else {
                    Logic.sharedInstance.whoami = PLAYER2
                }
                println("I'm(\(selfID.displayName)) set to \(Logic.sharedInstance.whoami.name)")
                // shake back
                self.shakeHandWithPeer()
            }
            //dismiss the mpc browser if presents
            let browser = appDelegate.mcHandler.browser
            if (browser.isViewLoaded() || browser.isBeingPresented()) && (!browser.isBeingDismissed()){
                appDelegate.mcHandler.browser.dismissViewControllerAnimated(true, completion: nil)
            }
            if !Logic.sharedInstance.isStarted {
                self.menuScene?.startNewGame()
            }
        } else if let action = message["updatePositions"] as? NSDictionary {
            for (name, update) in action {
                var piece: Piece? = appDelegate.gameScene?.pieceWithName(name as String)
                if let piece: Piece = piece {
                    piece.stopMotion()
                    piece.living = update["living"] as Bool
                    let position = update["position"] as NSDictionary
                    piece.position.x = position["x"] as CGFloat
                    piece.position.y = position["y"] as CGFloat
                } else {
                    println("piece not found in scene: \(name)")
                }
            }
            Logic.sharedInstance.stopBlockProcessing()
        } else if let action = message["applySkill"] as? NSDictionary {
            let pieceName = action["pieceName"] as String
            let skillName = action["skillName"] as String
            
            if let piece = appDelegate.gameScene?.pieceWithName(pieceName) {
                appDelegate.gameScene?.triggerSKill(piece, name: skillName)
            }
        } else {
            println("error: wrong exchanged data! \(receivedData)")
        }
    }

    func handleStateChange(notification: NSNotification){
        let userInfo = notification.userInfo! as Dictionary
        let state:String = userInfo["state"] as String
        let peerID: MCPeerID = userInfo["peerID"] as MCPeerID
        if state == "NotConnected" {
            presentAlert("\(peerID.displayName) state changed to \(state)")
            NSNotificationCenter.defaultCenter().postNotificationName(kShouldPresentMenuSceneNotification, object: appDelegate.gameScene, userInfo: nil)
        }
    }

    func endMCSession() {
        appDelegate.mcHandler.session.disconnect()
    }
    
    func shouldDisplayOnlineSearch() {
        connectWithPlayer(nil)
    }
    
    func shouldDisplayTutorial(){
        println("present tutorial")
        var tutorialViewController = TutorialViewController()
        self.presentViewController(tutorialViewController, animated: true, completion: nil)
    }
    
    func presentAlert(message: String) {
        let alert = UIAlertController(title: "WildPiece", message: message, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}