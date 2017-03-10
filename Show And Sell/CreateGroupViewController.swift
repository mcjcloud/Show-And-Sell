//
//  CreateGroupViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 12/16/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//
//  UIViewController implementation to prompt a user for details to create a group (POST to server).
//

import UIKit
import MapKit

class CreateGroupViewController: UIViewController, UITextViewDelegate {

    @IBOutlet var doneButton: UIBarButtonItem!
    var activityView: UIActivityIndicatorView!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var locationButton: UIButton!
    @IBOutlet var locationDetailField: UITextView!
    var annotation: MKPointAnnotation?
    var address: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // enable/disable done button
        doneButton.isEnabled = shouldEnableDoneButton()
        
        // assign textfields to text changed function
        nameField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        setupTextField(nameField)
        
        // make textfields dismiss when uiview tapped
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        // setup activityIndicatorItem
        self.activityView = UIActivityIndicatorView(activityIndicatorStyle: .white)
        activityView.hidesWhenStopped = true

        // assign necessary delegates
        locationDetailField.delegate = self
    }
    
    // MARK: TextView Delegate
    func textViewDidEndEditing(_ textView: UITextView) {
        doneButton.isEnabled = shouldEnableDoneButton()
        if textView.text == "" {
            textView.text = "Location Details"
        }
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Location Details" {
            textView.text = ""
        }
    }

    // MARK: Navigation
    @IBAction func unwindToCreateGroup(_ segue: UIStoryboardSegue) {
        if let annotation = (segue.source as? ChooseLocationViewController)?.selectedAnnotation {
            print("annotation: \(annotation)")
            self.locationButton.setTitle("\(annotation.title!)", for: .normal)
            self.annotation = annotation
            
            doneButton.isEnabled = shouldEnableDoneButton()
        }
    }
    @IBAction func done(_ sender: UIBarButtonItem) {
        // start load animation
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityView)
        activityView.startAnimating()
        
        // make the create group request
        let address = annotation!.subtitle
        let newGroup = Group(name: nameField.text!, adminId: AppDelegate.user?.userId ?? "", address: address ?? "Address not specified", latitude: annotation!.coordinate.latitude, longitude: annotation!.coordinate.longitude, locationDetail: locationDetailField.text!)
        HttpRequestManager.post(group: newGroup, password: AppDelegate.user?.password ?? "") { group, response, error in
            print("response: \(response as! HTTPURLResponse)")
            // stop animation
            self.activityView.stopAnimating()
            self.navigationItem.rightBarButtonItem = self.doneButton
            
            // response code parse
            let responseCode = (response as! HTTPURLResponse).statusCode
            var message: String?
            switch responseCode {
            case 200:
                AppDelegate.myGroup = group
                message = nil
            case 400:
                message = "Bad Request: Some information is already taken."
            default:
                message = "\(response)"
            }
            
            print("message: \(message)")
            if let m = message {
                DispatchQueue.main.async {
                    print("showing errorAlert for create group")
                    let errorAlert = UIAlertController(title: "Group not created.", message: m, preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .default) { action in
                        // return to the calling view controller
                        self.dismiss(animated: true)
                    }
                    
                    errorAlert.addAction(dismissAction)
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }
            else {
                // return (group created)
                self.dismiss(animated: true)
            }
            
        }
    }
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        dismissKeyboard()
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: Helper
    func textChanged(_ textField: UITextField) {
        doneButton.isEnabled = shouldEnableDoneButton()
    }
    
    // setup the custom TextField
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
    
    // dismiss a keyboard
    func dismissKeyboard() {
        nameField.resignFirstResponder()
        locationDetailField.resignFirstResponder()
    }
    
    // returns true if all fields are filled.
    func shouldEnableDoneButton() -> Bool {
        print("char count: \(nameField.text?.characters.count)")
        print("locdetail: \(locationDetailField.text.characters.count)")
        print("annotation: \(annotation != nil)")
        return nameField.text?.characters.count ?? 0 > 0 &&
            locationDetailField.text.characters.count > 0 &&
            annotation != nil
    }
}
