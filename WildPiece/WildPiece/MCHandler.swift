//
//  MCHandler.swift
//  WildPiece
//
//  Created by Guocheng Xie on 10/27/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

class MCHandler: NSObject, MCSessionDelegate {
    
    var peerID:MCPeerID!
    var session:MCSession!
    var browser:MCBrowserViewController!
    var advertiser:MCAdvertiserAssistant? = nil
    var UDID: String! {
        get {
            if NSUserDefaults.standardUserDefaults().stringForKey("UDID") == nil {
                NSUserDefaults.standardUserDefaults().setObject(UIDevice.currentDevice().identifierForVendor.UUIDString, forKey: "UDID")
            }
            return NSUserDefaults.standardUserDefaults().stringForKey("UDID")
        }
    }
    
    func setupPeerWithDisplayName(displayName: String) {
        peerID = MCPeerID(displayName: displayName)
    }
    
    func setupSession() {
        session = MCSession(peer: peerID)
        session.delegate = self
    }
    
    func setupBrowser() {
        browser = MCBrowserViewController(serviceType: "my-game", session: session)
        
    }
    
    func advertiseSelf(advertise:Bool){
        if advertise {
            advertiser = MCAdvertiserAssistant(serviceType: "my-game", discoveryInfo: nil, session: session)
            advertiser?.start()
        } else {
            advertiser?.stop()
            advertiser = nil
        }
    }
    
    func session(session: MCSession!, peer peerID: MCPeerID!, didChangeState state: MCSessionState) {
        let userInfo = ["peerID":peerID,"state":state.rawValue]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("MC_DidChangeStateNotification", object: nil, userInfo: userInfo)
        })
        
    }
    
    func session(session: MCSession!, didReceiveData data: NSData!, fromPeer peerID: MCPeerID!) {

        let userInfo = ["data":data, "peerID":peerID, "UDID":UDID]
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("MC_DidReceiveDataNotification", object: nil, userInfo: userInfo)
        })
        
    }
    
    
    func session(session: MCSession!, didFinishReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, atURL localURL: NSURL!, withError error: NSError!) {
        
    }
    
    func session(session: MCSession!, didStartReceivingResourceWithName resourceName: String!, fromPeer peerID: MCPeerID!, withProgress progress: NSProgress!) {

    }
    
    func session(session: MCSession!, didReceiveStream stream: NSInputStream!, withName streamName: String!, fromPeer peerID: MCPeerID!) {
        
    }
}
