//
//  EditNameViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 3/7/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit

class EditNameViewController: UIViewController, UITextFieldDelegate {

    // MARK: UI Properties
    @IBOutlet var firstNameField: UITextField!
    @IBOutlet var lastNameField: UITextField!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    // MARK: Properties
    var firstName: String!
    var lastName: String!
    var overlay = OverlayView(type: .loading, text: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // edit TextFields
        setupTextField(firstNameField)
        setupTextField(lastNameField)
        
        // make textfields dismiss when uiview tapped
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        // assign textfields data
        firstNameField.text = firstName
        lastNameField.text = lastName
        
        // set saveButton.isEnabled
        saveButton.isEnabled = shouldEnableSave()
    }
    
    // MARK: Helper
    func setupTextField(_ textfield: UITextField) {
        // edit password field
        let width = CGFloat(1.5)
        let border = CALayer()
        border.borderColor = UIColor(colorLiteralRed: 0.298, green: 0.686, blue: 0.322, alpha: 1.0).cgColor // Green
        border.frame = CGRect(x: 0, y: textfield.frame.size.height - width, width:  textfield.frame.size.width, height: textfield.frame.size.height)
        
        border.borderWidth = width
        textfield.layer.addSublayer(border)
        textfield.layer.masksToBounds = true
        textfield.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
    }
    
    func textChanged(_ textField: UITextField) {
        saveButton.isEnabled = shouldEnableSave()
    }
    
    func shouldEnableSave() -> Bool {
        return firstNameField.text?.characters.count ?? 0 > 0 && lastNameField.text?.characters.count ?? 0 > 0
    }
    
    // dismiss a keyboard
    func dismissKeyboard() {
        firstNameField.resignFirstResponder()
        lastNameField.resignFirstResponder()
    }
    
    func displayError(text: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Error", message: text, preferredStyle: .alert)
            let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
            
            alert.addAction(dismissAction)
            self.present(alert, animated: true, completion: nil)
        }
    }

    // MARK: IBAction
    @IBAction func saveName(_ sender: UIBarButtonItem) {
        // display loading wheel
        overlay.showOverlay(view: UIApplication.shared.keyWindow!, position: .center)
        
        if let user = AppDelegate.user {
            overlay.showOverlay(view: UIApplication.shared.keyWindow!, position: .center)
            user.firstName = firstNameField.text!
            user.lastName = lastNameField.text!
            HttpRequestManager.put(user: user, currentPassword: user.password) { user, response, error in
                
                // hide overlay
                DispatchQueue.main.async {
                    self.overlay.hideOverlayView()
                }
                
                if let u = user {
                    AppDelegate.user = u
                    // Dismiss this
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
                else {
                    // error getting user
                    self.displayError(text: "Error verifying success of update.")
                }
            }
        }
        else {
            self.displayError(text: "An error occurred. Try again.")
        }
    }
    
}
