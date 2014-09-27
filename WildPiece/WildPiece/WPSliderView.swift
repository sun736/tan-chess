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
    self.addSubview(contentView)
    slider.layer.borderWidth = 1
    slider.layer.borderColor = UIColor.blackColor().CGColor
    layer.borderWidth = 1
    layer.borderColor = UIColor.redColor().CGColor
  }
  
  func setupBasic(#title : String, minValue : Float, maxValue : Float) {
    titleLabel.text = title
    slider.minimumValue = minValue
    slider.maximumValue = maxValue
    slider.value = (minValue + maxValue) / 2
    valueLabel.text = "\(slider.value)"
  }
}
