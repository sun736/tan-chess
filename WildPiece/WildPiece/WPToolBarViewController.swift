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
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        massSlider.setupBasic(title: "M", minValue: 1, maxValue: 50, delegate: self)
        dampingSlider.setupBasic(title: "D", minValue: 1, maxValue: 25, delegate: self)
        restitutionSlider.setupBasic(title: "R", minValue: 0, maxValue: 1, delegate: self)
        impulseSlider.setupBasic(title: "I", minValue: 1, maxValue: 5, delegate: self)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateContents", name: "kUpdateToolBarNotification", object: nil)
    }
    
    func sliderValueDidChange(#slider : WPSliderView, didMoveToValue value : Double) {
        switch slider {
        case massSlider : WPParameterSet.sharedInstance.mass = value
        case dampingSlider : WPParameterSet.sharedInstance.damping = value
        case restitutionSlider : WPParameterSet.sharedInstance.restitution = value
        case impulseSlider : WPParameterSet.sharedInstance.impulse = value * kImpulseFactor
        default: println("Error when setting Slider value")
        }
        WPParameterSet.sharedInstance.saveParameterSet()
    }

    func updateContents() {
        titleLabel.text = WPParameterSet.sharedInstance.currentIdentifier
        massSlider.setSliderValue(WPParameterSet.sharedInstance.mass)
        dampingSlider.setSliderValue(WPParameterSet.sharedInstance.damping)
        restitutionSlider.setSliderValue(WPParameterSet.sharedInstance.restitution)
        impulseSlider.setSliderValue(WPParameterSet.sharedInstance.impulse)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
