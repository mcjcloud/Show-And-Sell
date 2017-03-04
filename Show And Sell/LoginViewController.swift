//
//  ViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/5/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//
//  UIViewController implementation to show a Login screen for accessing the server
//

import UIKit
import Google
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    // GUI properties
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var loginButton: UIButton!
    @IBOutlet var googleButton: GIDSignInButton!
    @IBOutlet var createAccountButton: UIButton!
    
    var user: User!
    
    var autoLogin: Bool = true
    
    var loadOverlay = OverlayView(type: .loading, text: "Loading...")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Login view did load")
        
        // configure google delegate
        var configureError: NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        //assert(configureError == nil, "Error configuring Google services: \(configureError)")
    
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        
        // set gray color for disabled button
        loginButton.setTitleColor(UIColor.gray, for: .disabled)
        createAccountButton.setTitleColor(UIColor.gray, for: .disabled)
        
        // adjust google button
        googleButton.colorScheme = .dark
        googleButton.addTarget(self, action: #selector(googleSignIn), for: .touchUpInside)
        
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
        
        logout()
        
        loginButton.isEnabled = true
        createAccountButton.isEnabled = true
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("dest from login: \(segue.destination)")
        // if the next view controller is the finder, give it a reference of self to know where to navigate next.
        if let dest = (segue.destination as? UINavigationController)?.childViewControllers[0] as? FindGroupTableViewController {
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
                self.postLogin(user: user, response: response, error: error)
            }
        }
        else {
            messageLabel.text = "Please make sure all fields are filled."
        }
    }
    
    // MARK: Google Auth
    func application(application: UIApplication, openURL url: URL, options: [String: Any]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication.rawValue] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation.rawValue])
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if (error == nil) {
            // Perform any operations on signed in user here.
            let userId = user.userID                  // For client-side use only!
            let email = user.profile.email
            let name = user.profile.name?.components(separatedBy: " ")
            let firstName = name?[0]
            let lastName = name?[1]
            
            // do sign in for google account
            print("userId: \(userId)")
            print("\(email) signed in")
            print("name: \(name)")
            if let email = email, let userId = userId, let firstName = firstName, let lastName = lastName {
                loadOverlay.showOverlay(view: self.view)
                HttpRequestManager.googleUser(email: email, userId: userId, firstName: firstName, lastName: lastName) { user, response, error in
                    print("calling postlogin from google sign in")
                    // finish login
                    self.postLogin(user: user, response: response, error: error)
                }
            }
        }
        else {
            print("signin error: \(error.localizedDescription)")
        }
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // disconnect
        print("google disconnect")
    }
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        // stop loading icon
        print("stop loading")
        loadOverlay.hideOverlayView()
    }
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        // present a sign in vc
        print("should present VC")
        self.present(viewController, animated: true, completion: nil)
    }
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        // dismiss the sign in vc
        print("should dismissVC")
        self.dismiss(animated: true, completion: nil)
    }

    // MARK: Helper
    func textChanged(_ textField: UITextField) {
        loginButton.isEnabled = shouldEnableLogin()
    }
    
    // check if the login button should be enabled.
    func shouldEnableLogin() -> Bool {
        return (emailField.text?.characters.count ?? 0) > 0 && (passwordField.text?.characters.count ?? 0) > 0
    }
    
    func postLogin(user: User?, response: URLResponse?, error: Error?) {
        
        print("postlogin response: \((response as! HTTPURLResponse).statusCode)")
        // stop any loading
        DispatchQueue.main.async {
            self.loadOverlay.hideOverlayView()
        }
        
        // check error
        if let e = error {
            print("error logging in: \(e)")
            // switch buttons and change message label in main thread
            DispatchQueue.main.async {
                self.messageLabel.text = "Error logging in."
                self.loginButton.isEnabled = true
                self.createAccountButton.isEnabled = true
            }
        }
        else if let u = user {
            print("user recieved: \(u.email)")
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
            DispatchQueue.main.async {
                if let status = (response as? HTTPURLResponse)?.statusCode {
                    // check error
                    switch(status) {
                    case 409:
                        self.messageLabel.text = "Account with gmail address already exists."
                        GIDSignIn.sharedInstance().signOut()
                    case 401:
                        self.messageLabel.text = "Incorrect username or password."
                    default:
                        self.messageLabel.text = "Error getting user."
                    }
                    
                }
                else {
                    // generic error message
                    self.messageLabel.text = "Error getting user."
                }
                
                // re-enable buttons
                self.loginButton.isEnabled = true
                self.createAccountButton.isEnabled = true
            }
        }
    }
    
    // when the google button is clicked
    func googleSignIn() {
        // clear message label
        messageLabel.text = ""
        print("google button clicked")
        loadOverlay.showOverlay(view: self.view)
    }
    
    // log the user out
    func logout() {
        // clear non-persistant data.
        AppDelegate.myGroup = nil
        AppDelegate.user = nil
        AppDelegate.group = nil
        AppDelegate.bookmarks = nil
        
        // logout google user
        GIDSignIn.sharedInstance().signOut()
    }
}

