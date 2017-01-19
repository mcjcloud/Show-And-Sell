//
//  SSTabBarViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/20/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

class SSTabBarViewController: UITabBarController {
    
    var loginVC: LoginViewController!                       // reference to login to prevent garbage collection.

    override func viewDidLoad() {
        super.viewDidLoad()
        /*
         * Perform actions needed when the user logs in.
         */
 
        // load the current group.
        if let groupId = AppDelegate.user?.groupId {
            // make an http request for the group.
            HttpRequestManager.getGroup(withId: groupId) { group, response, error in
                if let g = group {
                    AppDelegate.group = g
                }
                else {
                    self.present(FindGroupTableViewController(), animated: true) { () -> Void in
                        print("Chose initial group")
                    }
                }
                AppDelegate.saveData()
            }
        }
        
        // load the owned group
        HttpRequestManager.getGroup(with: AppDelegate.user?.userId ?? "") { group, response, error in
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

}
