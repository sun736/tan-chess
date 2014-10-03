//
//  WPToolBarViewController.swift
//  WildPiece
//
//  Created by Gabriel Yeah on 9/26/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import UIKit

class WPToolBarViewController: UIViewController, WPSliderViewDelegate {
    
    @IBOutlet weak var massSlider: WPSliderView!
    @IBOutlet weak var dampingSlider: WPSliderView!
    @IBOutlet weak var restitutionSlider: WPSliderView!
    @IBOutlet weak var impulseSlider: WPSliderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        massSlider.setupBasic(title: "M", minValue: 1, maxValue: 10, delegate: self)
        dampingSlider.setupBasic(title: "D", minValue: 1, maxValue: 25, delegate: self)
        restitutionSlider.setupBasic(title: "R", minValue: 0, maxValue: 1, delegate: self)
        impulseSlider.setupBasic(title: "I", minValue: 1, maxValue: 1000, delegate: self)
    }
    
    func sliderValueDidChange(#slider : WPSliderView, didMoveToValue value : Double) {
        switch slider {
        case massSlider : WPParameterHelper.sharedInstance.mass = value
        case dampingSlider : WPParameterHelper.sharedInstance.damping = value
        case restitutionSlider : WPParameterHelper.sharedInstance.restitution = value
        case impulseSlider : WPParameterHelper.sharedInstance.impulse = value
        default: println("Error when setting Slider value")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
