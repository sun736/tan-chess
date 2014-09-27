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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    massSlider.setupBasic(title: "M", minValue: 1, maxValue: 10)
    dampingSlider.setupBasic(title: "D", minValue: 1, maxValue: 25)
    // Do any additional setup after loading the view.
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
