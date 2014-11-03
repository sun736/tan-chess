//
//  TutorialImageViewController.swift
//  WildPiece
//
//  Created by Liu Yixiang on 11/3/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import UIKit

class TutorialImageViewController: UIViewController {

    var pageIndex : Int = 0
    var imageFile : String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: imageFile)!)
        /*var imageView = UIImageView(frame: CGRectMake(20, 50, 280, 450));
        var image = UIImage(named: imageFile);
        imageView.image = image;
        self.view.addSubview(imageView);*/

        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
