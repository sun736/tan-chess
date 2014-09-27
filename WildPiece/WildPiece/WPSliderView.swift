//
//  WPSliderView.swift
//  WildPiece
//
//  Created by Gabriel Yeah on 9/26/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import UIKit

class WPSliderView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    @IBOutlet var slider: UISlider!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NSBundle.mainBundle().loadNibNamed("WPSliderView", owner: self, options: nil)
        contentView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(contentView)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()  }
    
    func setConstraints() {
        var dict : [NSObject : AnyObject] = ["contentView" : contentView]
        var vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[contentView]-|",
            options: NSLayoutFormatOptions(0), metrics:nil, views: dict)
        var hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[contentView]-|",
            options: NSLayoutFormatOptions(0), metrics:nil, views: dict)
        
        addConstraints(vConstraints)
        addConstraints(hConstraints)
        updateConstraintsIfNeeded()
    }
    
    func setupBasic(#title : String, minValue : Float, maxValue : Float) {
        titleLabel.text = title
        slider.minimumValue = minValue
        slider.maximumValue = maxValue
        slider.value = (minValue + maxValue) / 2
        valueLabel.text = "\(slider.value)"
        setConstraints()
    }
    
    @IBAction func sliderDidChangeValue(sender: AnyObject) {
        println(slider.value)
        updateValueLabel(slider.value)
    }
    
    func updateValueLabel(value: Float) {
        valueLabel.text = "\(value)"
    }
}
