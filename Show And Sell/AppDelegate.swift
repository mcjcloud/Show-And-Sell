//
//  AppDelegate.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/5/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//
//  Show And Sell Yardale app.
//

import UIKit
import Google
import GoogleSignIn
import Braintree

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    // references to UI controllers
    static var loginVC: LoginViewController?
    static var tabVC: SSTabBarViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let enc = HttpRequestManager.encrypt("105697857720129832853")
        print("password: \(enc)")
        print("decrypted: \(HttpRequestManager.decrypt(enc))")
        
        BTAppSwitch.setReturnURLScheme("com.insertcoolnamehere.Show-And-Sell.payment")
        
        // load saved data.
        AppData.save = AppData.loadData() ?? SaveData(email: nil, password: nil, isGoogleSigned: false)
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        // save data
        AppData.saveData()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        // save data
        AppData.saveData()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // save data
        AppData.saveData()
        
        // log out of google
        GIDSignIn.sharedInstance().signOut()
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        print("opening URL: \(url.scheme)")
        if let scheme = url.scheme, scheme.contains("google") {   // google
            return GIDSignIn.sharedInstance().handle(url, sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplicationOpenURLOptionsKey.annotation])
        }
        else if let scheme = url.scheme, scheme.contains("showandsell") {       // twitter
                let components = url.absoluteString.components(separatedBy: "/")
                if components.count > 2 {
                    let id = components[components.count - 1]
                    print("making item request")
                    HttpRequestManager.item(id: id) { item, response, error in
                        AppData.displayItem = item
                        DispatchQueue.main.async {
                            if let _ = AppData.user {   // logged in
                                print("item returned")
                                let rootVC = self.window?.rootViewController as? LoginViewController
                                rootVC?.performSegue(withIdentifier: "loginToTabs", sender: rootVC)
                                SSTabBarViewController.shared.presentQueuedItem()
                            }
                            else {                          // not logged in
                                // show alert
                                let accountAlert = UIAlertController(title: "Log-In or Create Account", message: "You must create an account or sign in to an existing account to view this item.", preferredStyle: .alert)
                                accountAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                                    self.window?.rootViewController?.present(accountAlert, animated: true, completion: nil)
                            }
                        }
                    }
                }
            return false
        }
        else if url.scheme?.localizedCaseInsensitiveCompare("com.insertcoolnamehere.show-and-sell.payment") == .orderedSame {
            return BTAppSwitch.handleOpen(url, options: options)
        }
        else {
            return false
        }
    }

}

