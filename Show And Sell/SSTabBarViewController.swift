//
//  SSTabBarViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/20/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

class SSTabBarViewController: UITabBarController {
    
    static var shared: SSTabBarViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
        SSTabBarViewController.shared = self
        
        // select the middle tab
        self.selectedIndex = 1
        
        /*
         * Perform actions needed when the user logs in.
         */
        AppDelegate.tabVC = self    // give app delegate reference to this
        
        self.tabBar.unselectedItemTintColor = UIColor.white //UIColor(colorLiteralRed: 0.871, green: 0.788, blue: 0.380, alpha: 1.0)
 
        // load the current group.
        if let groupId = AppDelegate.user?.groupId {
            // make an http request for the group.
            HttpRequestManager.group(withId: groupId) { group, response, error in
                if let g = group {
                    AppDelegate.group = g
                }
                else {
                    DispatchQueue.main.async {
                        self.performSegue(withIdentifier: "tabsToFinder", sender: self)
                    }
                }
                AppDelegate.saveData()
            }
        }
        
        // load the owned group
        HttpRequestManager.group(withAdminId: AppDelegate.user?.userId ?? "") { group, response, error in
            AppDelegate.myGroup = group
            AppDelegate.saveData()
            
            if let e = error { print("error with owner group: \(e)") }
        }
        
        // load the bookmarks
        HttpRequestManager.bookmarks(forUserWithId: AppDelegate.user!.userId, password: AppDelegate.user!.password) { bookmarks, response, error in
            print("DATA RETURNED")
            
            // set current items to requested items
            if let b = bookmarks {
                AppDelegate.bookmarks = b
            }
        }
        
        // register for didBecomeActive notification
        //NotificationCenter.default.addObserver(self, selector: #selector(appBecameActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        presentQueuedItem()
    }
    func presentQueuedItem() {
        print("view appeared in tabs")
        // check if there's an item in need of display.
        if let item = AppDelegate.displayItem {
            print("item: \(item)")
            print("browseVC: \(self.childViewControllers[1].childViewControllers[0])")
            if let browseVC = self.childViewControllers[1].childViewControllers[0] as? BrowseCollectionViewController {
                print("showing item!")
                browseVC.performSegue(withIdentifier: "browseToDetail", sender: item)
                AppDelegate.displayItem = nil
            }
        }
    }
    
    // MARK: Helper functions
    
    // clear data of table view controllers
    func clearTabData() {
        print("clear data")
        clearBrowseData()
        clearBookmarksData()
    }
    
    func clearBrowseData() {
        // browse
        if let browseController = self.childViewControllers[1].childViewControllers[0] as? BrowseCollectionViewController {
            print("clearing browse")
            browseController.items = [Item]()
            browseController.filteredItems = [Item]()
        }
    }
    func clearBookmarksData() {
        // bookmarks
        if let bookmarkController = self.childViewControllers[0].childViewControllers[0] as? BookmarksTableViewController {
            print("clearing bookmarks")
            bookmarkController.bookmarkItems = [Item]()
            bookmarkController.bookmarks = [Item: String]()
        }
    }

}
