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
    var pages = [UIViewController]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // fix black bar at the bottom of pagevc
        UIPageControl.appearance().backgroundColor = UIColor(colorLiteralRed: 0.298, green: 0.686, blue: 0.322, alpha: 1.0)
        
        // set up page view controller
        self.delegate = self
        self.dataSource = self
        
        // populate vc array
        for i in 1...5 {
            let page: IntroViewController! = self.storyboard?.instantiateViewController(withIdentifier: "IntroController\(i)") as! IntroViewController
            pages.append(page)
        }
        let lastPage = self.storyboard!.instantiateViewController(withIdentifier: "IntroController6")
        pages.append(lastPage)
        
        setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
    }

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
        let currentIndex = pages.index(of: viewController)!
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
