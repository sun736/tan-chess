//
//  WPParameterHelper.swift
//  WildPiece
//
//  Created by Gabriel Yeah on 9/27/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import UIKit

class WPParameterHelper {
    // TODO: Create a signleton class in which the parameters will be managed.
    class var sharedInstance : WPParameterHelper {
        struct Static {
            static let instance : WPParameterHelper = WPParameterHelper()
        }
        return Static.instance
    }
    
    private var _mass = 5.5
    private var _damping = 13.0
    private var _restitution = 0.5
    private var _impulse = 500.0

    var mass : Double {
        set(mass) {
            if mass >= 0.0 && mass <= 10.0 {
                _mass = mass
            }
        }
        get { return _mass }
    }
    
    var damping : Double {
        set(damping) {
            if damping >= 0.0 && damping < 25.0 {
                _damping = damping
            }
        }
        get { return _damping }
    }
    
    var restitution : Double {
        set(restitution) {
            if restitution >= 0.0 && restitution <= 1.0 {
                _restitution = restitution
            }
        }
        get { return _restitution }
    }
    
    var impulse : Double {
        set(impulse) {
            if impulse >= 0.0 && impulse <= 100.0 {
                _impulse = impulse
            }
        }
        get { return _impulse }
    }
}
