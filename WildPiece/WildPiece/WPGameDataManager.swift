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
    var mass, damping, restitution, impulse : Double
//    var damping : Double
//    var restitution : Double
//    var impulse : Double
    
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

    var dataDict : NSDictionary?
    
    init() {
        var path = NSBundle.mainBundle().pathForResource("Game", ofType: "plist")
        dataDict = NSDictionary(contentsOfFile: path!)
    }
    
    func getParameterSet(forIdentifier identifier: String) {
        var rawDict : NSDictionary? = dataDict?.objectForKey(identifier as AnyObject) as? NSDictionary
        if let dict = rawDict {
            println(dict)
        }
    }
}
