//
//  ViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/5/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    // GUI properties
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var createAccountButton: UIButton!
    
    // refrence to tab bar controller to clear data
    var tabController: SSTabBarViewController?
    
    var user: User!
    
    var autoLogin: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        messageLabel.text = ""
        
        
        // auto login
        if let uname = AppDelegate.save.username, let pword = AppDelegate.save.password {
            usernameField.text = uname
            passwordField.text = pword
            
            if autoLogin {
                logIn(loginButton)
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Transition
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        print("unwind to login")
        // save data from session
        AppDelegate.saveData()
        
        // clear tab bar data
        print("tabController: \(self.tabController)")
        self.tabController?.clearTabData()
        
        // clear fields
        usernameField.text = ""
        passwordField.text = ""
        messageLabel.text = ""
        
        // clear non-persistant data.
        AppDelegate.myGroup = nil
        AppDelegate.user = nil
        AppDelegate.group = nil
        AppDelegate.bookmarks = nil
        
        loginButton.isEnabled = true
        createAccountButton.isEnabled = true
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? FindGroupTableViewController {
            dest.loginVC = self
        }
        else if let dest = segue.destination as? CreateAccountViewController {
            dest.loginVC = self
        }
        else if let dest = segue.destination as? SSTabBarViewController {
            dest.loginVC = self
        }
    }
    
    // IBOutlet functions
    @IBAction func logIn(_ sender: UIButton) {
        // GET user data.
        if let username = usernameField.text, let password = passwordField.text {
            // disable login button and create account button (until login attempt is complete)
            loginButton.isEnabled = false
            createAccountButton.isEnabled = false
        
            HttpRequestManager.getUser(withUsername: username, andPassword: password) { user, response, error in
                // check error
                
                if let _ = error {
                    self.messageLabel.text = "Error logging in."
                    self.loginButton.isEnabled = true
                    self.createAccountButton.isEnabled = true
                }
                else if let u = user {
                    self.user = u
                    self.autoLogin = true
                    
                    // if the signed in user is not the same as the saved user, reasign the "save user"
                    AppDelegate.user = u
                    
                    AppDelegate.save.username = u.username
                    AppDelegate.save.password = u.password
                    
                    AppDelegate.saveData()
                    
                    // go to tabs segue from main thread
                    DispatchQueue.main.async(execute: {
                        print("Logging in, groupId: \(u.groupId)")
                        if let groupId = AppDelegate.user?.groupId, groupId.characters.count > 0 {
                            self.performSegue(withIdentifier: "loginToTabs", sender: self)
                        }
                        else {  // if there is no group, segue to choose a group
                            print("loginToFinder segue")
                            print("saved groupId: \(AppDelegate.user?.groupId)")
                            self.performSegue(withIdentifier: "loginToFinder", sender: self)
                        }
                    })
                    
                    // save data
                    AppDelegate.saveData()
                }
                else {
                    // Tell user the process failed.
                    self.messageLabel.text = "Error getting user. Please make sure username and password are correct."
                    
                    // re-enable buttons
                    self.loginButton.isEnabled = true
                    self.createAccountButton.isEnabled = true
                }
            }
        }
        else {
            messageLabel.text = "Please make sure all fields are filled."
        }
    }

}

