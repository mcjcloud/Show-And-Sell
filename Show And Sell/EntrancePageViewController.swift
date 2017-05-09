//
//  EntrancePageViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 5/8/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit

class EntrancePageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, LoginViewControllerDelegate, CreateAccountViewControllerDelegate {

    var pages: [UIViewController] = [UIViewController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.delegate = self
        self.dataSource = self
        
        // create view contollers
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as? LoginViewController
        loginVC?.delegate = self
        let createVC = self.storyboard?.instantiateViewController(withIdentifier: "createVC") as? CreateAccountViewController
        createVC?.delegate = self
        
        pages.append(loginVC!)
        pages.append(createVC!)
        setViewControllers([pages[0]], direction: .forward, animated: false, completion: nil)
    }
    
    // MARK: PageViewController data source and delegate
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let currentIndex = pages.index(of: viewController)!
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
    
    // MARK: page delegates
    func login(didPressCreateButton createButton: UIButton) {
        setViewControllers([pages[1]], direction: .forward, animated: true, completion: nil)
    }
    
    func create(didPressLoginButton loginButton: UIButton) {
        setViewControllers([pages[0]], direction: .reverse, animated: true, completion: nil)
    }
}
