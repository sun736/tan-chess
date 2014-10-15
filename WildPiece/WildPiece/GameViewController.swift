//
//  GameViewController.swift
//  WildPiece
//
//  Created by Amelech on 9/26/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import UIKit
import SpriteKit

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

class GameViewController: UIViewController {
    
    @IBOutlet weak var toolBarContainerView: UIView!
    @IBOutlet weak var switchControl: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
            
            let menuScene = MenuScene(size: scene.size)
            
            skView.presentScene(menuScene)
        }
        
        self.switchControl.on = false
        self.toolBarContainerView.alpha = 0.0
        
        WPParameterSet.sharedInstance.updateCurrentParameterSet(forIdentifier: "King")
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
}
