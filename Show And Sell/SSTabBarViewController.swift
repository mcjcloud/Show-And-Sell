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
        if let groupId = AppData.user?.groupId {
            // make an http request for the group.
            HttpRequestManager.group(withId: groupId) { group, response, error in
                if let g = group {
                    AppData.group = g
                }
                AppData.saveData()
            }
        }
        
        // load the owned group
        HttpRequestManager.group(withAdminId: AppData.user?.userId ?? "") { group, response, error in
            AppData.myGroup = group
            AppData.saveData()
            
            if let e = error { print("error with owner group: \(e)") }
        }
        
        // load the bookmarks
        HttpRequestManager.bookmarks(forUserWithId: AppData.user!.userId, password: AppData.user!.password) { bookmarks, response, error in
            print("DATA RETURNED")
            
            // set current items to requested items
            if let b = bookmarks {
                AppData.bookmarks = b
            }
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        presentQueuedItem()
    }
    
    func presentQueuedItem() {
        print("view appeared in tabs")
        // check if there's an item in need of display.
        if let item = AppData.displayItem {
            if let browseVC = self.childViewControllers[1].childViewControllers[0] as? BrowseCollectionViewController {
                self.selectedIndex = 1
                browseVC.performSegue(withIdentifier: "browseToDetail", sender: item)
                AppData.displayItem = nil
            }
        }
    }
    
    // MARK: Helper functions
    
    // clear data of table view controllers
    func clearTabData() {
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
