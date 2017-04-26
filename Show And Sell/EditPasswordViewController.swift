//
//  EditPasswordViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 3/7/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit

class EditPasswordViewController: UIViewController {

    // MARK: UI Properties
    @IBOutlet var oldPasswordField: UITextField!
    @IBOutlet var newPasswordField: UITextField!
    @IBOutlet var saveButton: UIBarButtonItem!
    
    // MARK: Properties
    var oldPassword: String!
    var newPassword: String!
    var overlay = OverlayView(type: .loading, text: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // setup textfields
        setupTextField(oldPasswordField)
        setupTextField(newPasswordField)
        
        // make textfields dismiss when uiview tapped
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))

        // assign textfields data
        oldPasswordField.text = oldPassword
        newPasswordField.text = newPassword
        
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
    
    // dismiss a keyboard
    func dismissKeyboard() {
        oldPasswordField.resignFirstResponder()
        newPasswordField.resignFirstResponder()
    }
    
    func shouldEnableSave() -> Bool {
        return oldPasswordField.text?.characters.count ?? 0 > 0 && newPasswordField.text?.characters.count ?? 0 > 0
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
    @IBAction func savePassword(_ sender: UIBarButtonItem) {
        // show overlay
        overlay.showOverlay(view: UIApplication.shared.keyWindow!, position: .center)
        
        if let user = AppDelegate.user {
            overlay.showOverlay(view: UIApplication.shared.keyWindow!, position: .center)
            user.password = newPasswordField.text!
            HttpRequestManager.put(user: user, currentPassword: oldPasswordField.text ?? "") { user, response, error in
                
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
