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

class GameViewController: UIViewController, MCBrowserViewControllerDelegate, MenuSceneDelegate, GameSceneDelegate{
    
    @IBOutlet weak var toolBarContainerView: UIView!
    @IBOutlet weak var switchControl: UISwitch!
    
    var appDelegate  : AppDelegate!
    var menuScene : MenuScene?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.appDelegate.mcHandler.setupPeerWithDisplayName(UIDevice.currentDevice().name)
        self.appDelegate.mcHandler.setupSession()
        self.appDelegate.mcHandler.advertiseSelf(true)
        
        appDelegate.gameScene?.sceneDelegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "presentMenuScene:",
            name: kShouldPresentMenuSceneNotification, object: nil)
        
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
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "peerChangedStateWithNotification:", name: "MC_DidChangeStateNotification", object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleReceivedDataWithNotification:", name: "MC_DidReceiveDataNotification", object: nil)
        
    }
    
    func browserViewControllerDidFinish(browserViewController: MCBrowserViewController!) {
        
        self.menuScene?.startNewGame()
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
    
    func sendDataToPeer() {
        let messageDict = ["field": UIDevice.currentDevice().name]
        
        let messageData = NSJSONSerialization.dataWithJSONObject(messageDict, options: NSJSONWritingOptions.PrettyPrinted, error: nil)
        
        var error:NSError?
        
        appDelegate.mcHandler.session.sendData(messageData, toPeers: appDelegate.mcHandler.session.connectedPeers, withMode: MCSessionSendDataMode.Reliable, error: &error)
        
        if error != nil{
            println("error: \(error?.localizedDescription)")
        }
    }
    
    func handleReceivedDataWithNotification(notification:NSNotification){
        let userInfo = notification.userInfo! as Dictionary
        let receivedData:NSData = userInfo["data"] as NSData
        
        let message = NSJSONSerialization.JSONObjectWithData(receivedData, options: NSJSONReadingOptions.AllowFragments, error: nil) as NSDictionary
        let senderPeerId:MCPeerID = userInfo["peerID"] as MCPeerID
        let senderDisplayName = senderPeerId.displayName
        
        let alert = UIAlertController(title: "WildPiece", message: "\(senderDisplayName) has started a new Game", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }

    
    func shouldDisplayOnlineSearch() {
        connectWithPlayer(nil)
    }
}
