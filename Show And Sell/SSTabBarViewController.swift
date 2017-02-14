//
//  SSTabBarViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/20/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

class SSTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // select the middle tab
        self.selectedIndex = 1
        
        /*
         * Perform actions needed when the user logs in.
         */
        AppDelegate.tabVC = self    // give app delegate reference to this
 
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
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Helper functions
    
    // clear data of table view controllers
    func clearTabData() {
        print("clear data")
        clearBrowseData()
        clearBookmarksData()
    }
    
    func clearBrowseData() {
        // browse
        if let browseController = self.childViewControllers[0].childViewControllers[0] as? BrowseTableViewController {
            print("clearing browse")
            browseController.items = [Item]()
            browseController.filteredItems = [Item]()
        }
    }
    func clearBookmarksData() {
        // bookmarks
        if let bookmarkController = self.childViewControllers[1].childViewControllers[0] as? BookmarksTableViewController {
            print("clearing bookmarks")
            bookmarkController.bookmarkItems = [Item]()
            bookmarkController.bookmarks = [Item: String]()
        }
    }

}
