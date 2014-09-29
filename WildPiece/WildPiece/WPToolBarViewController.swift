//
//  WPToolBarViewController.swift
//  WildPiece
//
//  Created by Gabriel Yeah on 9/26/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import UIKit

class WPToolBarViewController: UIViewController {
    
    @IBOutlet weak var massSlider: WPSliderView!
    @IBOutlet weak var dampingSlider: WPSliderView!
    @IBOutlet weak var restitutionSlider: WPSliderView!
    @IBOutlet weak var impulseSlider: WPSliderView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        massSlider.setupBasic(title: "M", minValue: 1, maxValue: 10)
        dampingSlider.setupBasic(title: "D", minValue: 1, maxValue: 25)
        restitutionSlider.setupBasic(title: "R", minValue: 0, maxValue: 1)
        impulseSlider.setupBasic(title: "I", minValue: 1, maxValue: 1000)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}