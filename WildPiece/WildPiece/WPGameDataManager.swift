//
//  WPGameDataManager.swift
//  WildPiece
//
//  Created by Gabriel Yeah on 9/27/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import UIKit

struct WPParameterSet {
    var identifier : String
    var mass, damping, restitution, impulse : Double?

    static var sharedInstance : WPParameterSet = WPParameterSet()
    
    init() {
        self.init(identifier : "King", mass : 20.0, damping : 10.0, restitution : 0.5, impulse : 100.0)
    }
    
    init(identifier : String, mass : Double, damping : Double, restitution : Double, impulse : Double) {
        self.identifier = identifier
        self.mass = mass
        self.damping = damping
        self.restitution = restitution
        self.impulse = impulse
    }

}

struct WPGameDataManager {
    // TODO: Create a signleton class in which the parameters will be managed.
    static var sharedInstance : WPGameDataManager = WPGameDataManager()

    var dataDict : NSMutableDictionary?
    
    init() {
        var path = NSBundle.mainBundle().pathForResource("Game", ofType: "plist")
        dataDict = NSMutableDictionary(contentsOfFile: path!)
    }
    
    func getParameterSet(forIdentifier identifier: String) {
        var rawDict : NSDictionary? = dataDict?.objectForKey(identifier as AnyObject) as? NSDictionary
        if let dict = rawDict {
            WPParameterSet.sharedInstance.identifier = identifier
            WPParameterSet.sharedInstance.mass = (dict.objectForKey("mass") as? NSNumber)?.doubleValue
            WPParameterSet.sharedInstance.damping = (dict.objectForKey("damping") as? NSNumber)?.doubleValue
            WPParameterSet.sharedInstance.restitution = (dict.objectForKey("restitution") as? NSNumber)?.doubleValue
            WPParameterSet.sharedInstance.impulse = (dict.objectForKey("impulse") as? NSNumber)?.doubleValue
        }
    }
    
    func saveParameterSet(forIdentifier identifier: String) {
        var rawDict : NSMutableDictionary? = dataDict?.objectForKey(identifier as AnyObject) as? NSMutableDictionary
        if var dict = rawDict {
            dict.setValue(WPParameterSet.sharedInstance.mass as AnyObject?, forKey: "mass")
            dict.setValue(WPParameterSet.sharedInstance.damping as AnyObject?, forKey: "damping")
            dict.setValue(WPParameterSet.sharedInstance.restitution as AnyObject?, forKey: "restitution")
            dict.setValue(WPParameterSet.sharedInstance.impulse as AnyObject?, forKey: "impulse")
            
            dataDict?.setValue(dict, forKey: identifier)
        }
    }
}
