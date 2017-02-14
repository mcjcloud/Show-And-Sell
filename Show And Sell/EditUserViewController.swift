//
//  EditUserViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 2/8/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit

class EditUserViewController: UIViewController {
    
    var activityView: UIActivityIndicatorView!

    @IBOutlet var saveButton: UIBarButtonItem!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var newPasswordField: UITextField!
    @IBOutlet var confirmPasswordField: UITextField!
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.title = "Edit Account"
        
        // activity indicator for request laoding
        self.activityView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        
        // assign textChanged to text fields
        emailField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        newPasswordField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        confirmPasswordField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        firstNameField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        lastNameField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        
        if let user = AppDelegate.user {
            // fill out the current user settings.
            emailField.text = user.email
            firstNameField.text = user.firstName
            lastNameField.text = user.lastName
        }
    }
    
    @IBAction func save(_ sender: UIBarButtonItem) {
        // Make user HTTP request
        // check the state of the password field
        if newPasswordField.text != confirmPasswordField.text {       // if the old password field is filled out.
            let matchAlert = UIAlertController(title: "Passwords must match.", message: "The New Password field and Confirm Password field do not match.", preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            matchAlert.addAction(dismissAction)
            present(matchAlert, animated: true, completion: nil)
        }
        else {
            // start animation
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityView)
            activityView.startAnimating()
            
            if let user = AppDelegate.user {
                // make alert to ask for old Password
                let passwordAlert = UIAlertController(title: "Enter Password", message: "Enter your current password to confirm.", preferredStyle: .alert)
                passwordAlert.addTextField(configurationHandler: nil)
                let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
                let confirmAction = UIAlertAction(title: "Confirm", style: .default) { action in
                    
                    if let oldPassword = passwordAlert.textFields?[0].text {    // get the text from the text field.
                        
                        // get data for PUT request
                        let newEmail = self.emailField.text ?? user.email
                        let newPassword = (self.newPasswordField.text?.characters.count ?? 0 > 0) ? self.newPasswordField.text! : user.password
                        let firstName = self.firstNameField.text ?? user.firstName
                        let lastName = self.lastNameField.text ?? user.lastName
                        
                        // update user properties
                        user.email = newEmail
                        user.password = newPassword
                        user.firstName = firstName
                        user.lastName = lastName
                        
                        // make HTTP request
                        HttpRequestManager.put(user: user, currentPassword: oldPassword) { user, response, error in
                            // stop animation
                            self.activityView.stopAnimating()
                            self.navigationItem.rightBarButtonItem = self.saveButton
                            
                            // set the AppDelegate user to the returned user
                            if let u = user {
                                AppDelegate.user = u
                                
                                // pop the view controller in the main thread
                                DispatchQueue.main.async {
                                    let _ = self.navigationController?.popViewController(animated: true)
                                }
                            
                                print("USER UPDATED")
                            }
                            else {
                                var message: String?
                                let httpResponse = response as! HTTPURLResponse
                                switch httpResponse.statusCode {
                                case 200:
                                    message = nil
                                    print("PUT User OK")
                                case 401:
                                    message = "Password is incorrect."
                                default:
                                    message = httpResponse.description
                                }
                                
                                DispatchQueue.main.async {
                                    // display error message from the server
                                    let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                                    let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                                    errorAlert.addAction(dismissAction)
                                    self.present(errorAlert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
                passwordAlert.addAction(cancelAction)
                passwordAlert.addAction(confirmAction)
                present(passwordAlert, animated: true, completion: nil)
                
            }
            else {      // user is nil
                // TODO: handle this
            }
        }
    }

    // MARK: Helper
    func textChanged(_ textField: UITextField) {
        saveButton.isEnabled = shouldEnableSaveButton()
    }
    
    // returns true if fields are filled
    func shouldEnableSaveButton() -> Bool {
        return emailField.text?.characters.count ?? 0 > 0 &&
            firstNameField.text?.characters.count ?? 0 > 0 &&
            lastNameField.text?.characters.count ?? 0 > 0 &&
            (newPasswordField.text?.characters.count ?? 0 > 0 ?             //
                confirmPasswordField.text?.characters.count ?? 0 > 0 :      // either they're both empty or both have something.
                confirmPasswordField.text?.characters.count ?? 0 == 0)      //
    }
}
