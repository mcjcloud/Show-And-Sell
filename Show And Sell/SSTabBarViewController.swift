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
        /*
         * Perform actions needed when the user logs in.
         */
 
        // load the current group.
        if AppDelegate.save.group != nil && AppDelegate.save.group != "" {
            // make an http request for the group.
            HttpRequestManager.getGroup(withId: AppDelegate.save.group!) { group, response, error in
                AppDelegate.group = group
            }
        }
        // load the bookmarks
        HttpRequestManager.getBookmarks(with: AppDelegate.user!.userId, password: AppDelegate.user!.password) { bookmarks, response, error in
            
            if let e = error {
                print("error: \(e)")
            }
            else {
                AppDelegate.bookmarks = bookmarks
            }
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

}
