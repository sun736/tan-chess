//
//  WPParameterSet.swift
//  WildPiece
//
//  Created by Gabriel Yeah on 9/27/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import UIKit

struct WPParameterSet {
    var mass, damping, restitution, impulse : Double?
    var dataDict : NSMutableDictionary?
    var currentIdentifier : String?
    
    static var sharedInstance : WPParameterSet = WPParameterSet()
    let path = NSBundle.mainBundle().pathForResource("Game", ofType: "plist")
    
    init() {
        dataDict = NSMutableDictionary(contentsOfFile: path!)
    }
    
    mutating func updateCurrentParameterSet(forIdentifier identifier: String) {
        var rawDict : NSDictionary? = dataDict?.objectForKey(identifier as AnyObject) as? NSDictionary
        if let dict = rawDict {
            mass = (dict.objectForKey("mass") as? NSNumber)?.doubleValue
            damping = (dict.objectForKey("damping") as? NSNumber)?.doubleValue
            restitution = (dict.objectForKey("restitution") as? NSNumber)?.doubleValue
            impulse = (dict.objectForKey("impulse") as? NSNumber)?.doubleValue
        }
    }
    
    mutating func saveParameterSet(forIdentifier identifier: String) {
        var rawDict : NSMutableDictionary? = dataDict?.objectForKey(identifier as AnyObject) as? NSMutableDictionary
        if var dict = rawDict {
            dict.setValue(mass as AnyObject?, forKey: "mass")
            dict.setValue(damping as AnyObject?, forKey: "damping")
            dict.setValue(restitution as AnyObject?, forKey: "restitution")
            dict.setValue(impulse as AnyObject?, forKey: "impulse")
            
            dataDict?.setValue(dict, forKey: identifier)
            writeToPlist()
        }
    }
    
    func writeToPlist() {
        var path = NSBundle.mainBundle().pathForResource("Game", ofType: "plist")
        let fileManager = NSFileManager.defaultManager()
        dataDict?.writeToFile(path!, atomically: true)
    }
}
