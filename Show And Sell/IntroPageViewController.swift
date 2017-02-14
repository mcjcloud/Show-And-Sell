//
//  IntroPageViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/15/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

class IntroPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // Pages
    var pages = [IntroViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // set up page view controller
        self.delegate = self
        self.dataSource = self
        
        // create view controllers
        let page1: IntroViewController! = self.storyboard?.instantiateViewController(withIdentifier: "IntroController1") as! IntroViewController
        let page2: IntroViewController! = self.storyboard?.instantiateViewController(withIdentifier: "IntroController2") as! IntroViewController
        
        // add view controllers to array
        pages.append(page1)
        pages.append(page2)
        
        setViewControllers([page1], direction: .forward, animated: false, completion: nil)
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

    // MARK: PageViewController data source and delegate
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: (viewController as! IntroViewController))!
        let previousIndex = currentIndex - 1
        
        if previousIndex < 0 {
            return nil
        }
        
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: (viewController as! IntroViewController))!
        let nextIndex = currentIndex + 1
        
        if nextIndex >= pages.count {
            return nil
        }
        
        return pages[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    
}
