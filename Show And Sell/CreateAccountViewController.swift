//
//  CreateAccountViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/5/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//
//  UIViewController implementation to show a screen for creating an account.
//

import UIKit

class CreateAccountViewController: UIViewController {
    // GUI Outlets
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var emailField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var confirmPasswordField: UITextField!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var createAccountButton: UIButton!
    @IBOutlet var cancelButton: UIButton!
    
    var loginVC: LoginViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // edit TextFields
        setupTextField(firstNameField)
        setupTextField(lastNameField)
        setupTextField(emailField)
        setupTextField(passwordField)
        setupTextField(confirmPasswordField)
        
        // make textfields dismiss when uiview tapped
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

        
        // setup gray disabled colors
        createAccountButton.setTitleColor(UIColor.gray, for: .disabled)
        cancelButton.setTitleColor(UIColor.gray, for: .disabled)
        
        // setup method for textfields typing
        firstNameField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        lastNameField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        emailField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        confirmPasswordField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        
        messageLabel.text = ""
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if navigating to Finder, tell it where it came from
        print("source from create: \(self)")
        if let dest = (segue.destination as? UINavigationController)?.childViewControllers[0] as? FindGroupTableViewController {
            dest.previousVC = self
        }
    }

    // Create Account button action
    @IBAction func createAccount(_ sender: UIButton) {
        // disable button
        createAccountButton.isEnabled = false
        
        // check that the fields are filled.
        if let fName = firstNameField.text,
        let lName = lastNameField.text,
        let email = emailField.text,
        let pWord = passwordField.text,
        let cPWord = confirmPasswordField.text {
            if pWord == cPWord {
                let userToPost = User(email: email, password: HttpRequestManager.encrypt(pWord), firstName: fName, lastName: lName)
                HttpRequestManager.post(user: userToPost) { user, response, error in
                    
                    if let u = user {
                        // the user object is not nil
                        
                        // set the global user variable.
                        AppDelegate.user = u
                        
                        AppDelegate.save.email = u.email
                        AppDelegate.save.password = u.password
                        
                        // perform segue to Browse View Controller.
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "createToFinder", sender: self)
                        }
                        
                        // save data
                        AppDelegate.saveData()
                    }
                    else {
                        DispatchQueue.main.async {
                            self.messageLabel.text = "Error creating user. Check credentials."
                            // enable button
                            self.createAccountButton.isEnabled = true
                        }
                    }
                }
            }
            else {
                // handle passwords not matching in main thread.
                DispatchQueue.main.async {
                    self.messageLabel.text = "Passwords do not match."
                }
            }
        }
        // if the fields are not all filled out.
        else {
            DispatchQueue.main.async {
                self.messageLabel.text = "Please make sure all fields are filled."
            }
        }
    }

    // MARK: Helper
    
    // target for text change in UITextFields
    func textChanged(_ textField: UITextField) {
        createAccountButton.isEnabled = shouldEnableCreateButton()
    }
    
    // dismiss a keyboard
    func dismissKeyboard() {
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        confirmPasswordField.resignFirstResponder()
    }
    
    // returns true if the create account button should be enabled.
    func shouldEnableCreateButton() -> Bool {
        return firstNameField.text?.characters.count ?? 0 > 0 &&
            lastNameField.text?.characters.count ?? 0 > 0 &&
            emailField.text?.characters.count ?? 0 > 0 &&
            passwordField.text?.characters.count ?? 0 > 0 &&
            confirmPasswordField.text?.characters.count ?? 0 > 0
    }
    
    func setupTextField(_ textfield: UITextField) {
        // edit password field
        let width = CGFloat(1.5)
        let border = CALayer()
        border.borderColor = UIColor(colorLiteralRed: 0.298, green: 0.686, blue: 0.322, alpha: 1.0).cgColor // Green
        border.frame = CGRect(x: 0, y: textfield.frame.size.height - width, width:  textfield.frame.size.width, height: textfield.frame.size.height)
        
        border.borderWidth = width
        textfield.layer.addSublayer(border)
        textfield.layer.masksToBounds = true
    }
}
