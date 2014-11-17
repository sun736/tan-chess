//
//  TutorialViewController.swift
//  WildPiece
//
//  Created by Liu Yixiang on 11/3/14.
//  Copyright (c) 2014 Project TC. All rights reserved.
//

import UIKit

class TutorialViewController: UIViewController, UIPageViewControllerDataSource {

    var pageViewController: UIPageViewController?
    var pageImages : Array<String> = ["tutorial_knight", "tutorial_rook","tutorial_bishop","tutorial_pawn"]
    var currentIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var width = view.frame.size.width
        var height = view.frame.size.height
        
        
        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor(red: 150.0/255.0, green: 212.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        
        pageViewController = UIPageViewController(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        pageViewController?.dataSource = self
        
        var imageView: TutorialImageViewController = viewControllerAtIndex(0)!
        let viewControllers: NSArray = [imageView]
        pageViewController!.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: nil)
        pageViewController!.view.frame = CGRectMake(0, height*0.07, width, height*0.86)
        addChildViewController(pageViewController!)
        view.addSubview(pageViewController!.view)
        pageViewController!.didMoveToParentViewController(self)
        
        //add a back button
        let backButton = UIButton()
        backButton.setTitle("Back", forState:.Normal)
        backButton.titleLabel!.font =  UIFont(name: "Verdana", size: 20)
        backButton.frame = CGRectMake(width*0.1, height*0.92, width*0.8, width*0.1)
        backButton.addTarget(self, action: "pressBackButton:", forControlEvents: .TouchUpInside)
        //backButton.textColor = UIColor.whiteColor()
        view.addSubview(backButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Page view controller
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        var index = (viewController as TutorialImageViewController).pageIndex
        
        if ((index == 0) || (index == NSNotFound)) {
            return nil
        }

        index--
        
        return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
       
        var index = (viewController as TutorialImageViewController).pageIndex
        
        if index == NSNotFound {
            return nil
        }
        
        index++
        
        if (index == self.pageImages.count)
        {
            return nil
        }

        
        return viewControllerAtIndex(index)
    }

    func viewControllerAtIndex(index: Int) -> TutorialImageViewController?
    {
        if self.pageImages.count == 0 || index >= self.pageImages.count
        {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        let pageContentViewController = TutorialImageViewController()
        pageContentViewController.imageFile = pageImages[index]
        pageContentViewController.pageIndex = index
        currentIndex = index
        return pageContentViewController
    }
    
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return self.pageImages.count
    }
    
     func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0;
    }
    
    //MARK: Button press
    func pressBackButton(sender: UIButton!) {
         self.dismissViewControllerAnimated(true, completion: nil)
    }

}
