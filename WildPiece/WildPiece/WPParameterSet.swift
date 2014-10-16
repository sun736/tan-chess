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
    var radius, healthPoint, maxhealthPoint, angularDamping : Double?
    var dataDict : NSMutableDictionary?
    var currentIdentifier : String?
    
    static var sharedInstance : WPParameterSet = WPParameterSet()
    
    init() {
        dataDict = NSMutableDictionary(contentsOfFile: plistPath())
    }
    
    mutating func updateCurrentParameterSet(forIdentifier identifier: String?) {
        currentIdentifier = identifier
        if currentIdentifier == nil {
            return
        }
        
        var rawDict : NSMutableDictionary? = dataDict?.objectForKey(identifier! as AnyObject) as? NSMutableDictionary
        if let dict = rawDict {
            mass = (dict.objectForKey("mass") as? NSNumber)?.doubleValue
            damping = (dict.objectForKey("damping") as? NSNumber)?.doubleValue
            restitution = (dict.objectForKey("restitution") as? NSNumber)?.doubleValue
            impulse = (dict.objectForKey("impulse") as? NSNumber)?.doubleValue
            radius = (dict.objectForKey("radius") as? NSNumber)?.doubleValue
            healthPoint = (dict.objectForKey("healthPoint") as? NSNumber)?.doubleValue
            maxhealthPoint = (dict.objectForKey("maxhealthPoint") as? NSNumber)?.doubleValue
            angularDamping = (dict.objectForKey("angularDamping") as? NSNumber)?.doubleValue
        }
        NSNotificationCenter.defaultCenter().postNotificationName("kUpdateToolBarNotification", object: nil)
    }
    
    mutating func saveParameterSet() {
        if currentIdentifier == nil {
            return
        }
        dataDict?.writeToFile(plistPath(), atomically: true)
        NSNotificationCenter.defaultCenter().postNotificationName("kShouldApplyParameters", object: nil)
    }
    
    func plistPath() -> NSString {
        
        let fileManager = NSFileManager.defaultManager()
        var bundle = NSBundle.mainBundle().pathForResource("Game", ofType: "plist")!
        var paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String
        var path = paths + "/Game.plist"
        
        if !NSFileManager.defaultManager().createDirectoryAtPath(path, withIntermediateDirectories: true, attributes: nil, error: nil) {
            return path
        }
        
        if (!fileManager.fileExistsAtPath(path)) {
            fileManager.copyItemAtPath(bundle, toPath:path, error:nil)
        }
        println(path)
        return path
    }
}
