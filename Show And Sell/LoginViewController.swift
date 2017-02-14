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
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var createAccountButton: UIButton!
    
    var user: User!
    
    var autoLogin: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Login view did load")
        
        // set gray color for disabled button
        loginButton.setTitleColor(UIColor.gray, for: .disabled)
        createAccountButton.setTitleColor(UIColor.gray, for: .disabled)
        
        // assign textField methods
        emailField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        
        // Do any additional setup after loading the view, typically from a nib.
        AppDelegate.loginVC = self      // pass a reference to the AppDelegate
        messageLabel.text = ""
        
        // auto login
        if let email = AppDelegate.save.email, let pword = AppDelegate.save.password {
            emailField.text = email
            passwordField.text = pword
            
            if autoLogin {
                logIn(loginButton)
            }
        }
        
        // enable/disable login button
        loginButton.isEnabled = shouldEnableLogin()
    }
    override func viewWillAppear(_ animated: Bool) {
        // enable/disable login button
        loginButton.isEnabled = shouldEnableLogin()
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
        AppDelegate.tabVC?.clearTabData()
        
        // clear fields
        emailField.text = ""
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
        // if the next view controller is the finder, give it a reference of self to know where to navigate next.
        if let dest = segue.destination as? FindGroupTableViewController {
            dest.previousVC = self
        }
    }
    
    // IBOutlet functions
    @IBAction func logIn(_ sender: UIButton) {
        // clear error message
        messageLabel.text = ""
        
        // GET user data.
        if let email = emailField.text, let password = passwordField.text {
            // disable login button and create account button (until login attempt is complete)
            loginButton.isEnabled = false
            createAccountButton.isEnabled = false
        
            HttpRequestManager.user(withEmail: email, andPassword: password) { user, response, error in
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
                    
                    AppDelegate.save.email = u.email
                    AppDelegate.save.password = u.password
                    
                    AppDelegate.saveData()
                    
                    // go to tabs segue from main thread
                    DispatchQueue.main.async(execute: {
                        print("Logging in, groupId: \(u.groupId)")
                        if let groupId = AppDelegate.user?.groupId, groupId.characters.count > 0 {
                            print("segue to tabs")
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
                    self.messageLabel.text = "Error getting user. Please make sure email and password are correct."
                    
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

    // MARK: Helper
    func textChanged(_ textField: UITextField) {
        loginButton.isEnabled = shouldEnableLogin()
    }
    
    // check if the login button should be enabled.
    func shouldEnableLogin() -> Bool {
        return (emailField.text?.characters.count ?? 0) > 0 && (passwordField.text?.characters.count ?? 0) > 0
    }
}

