//
//  DontateItemViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/5/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//
//  UIViewController implementation to prompt the user for Item details for donating an item (posting it to server)
//

import UIKit

class DonateItemViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // UI Elements
    var activityView: UIActivityIndicatorView!
    @IBOutlet var itemNameField: UITextField!
    @IBOutlet var itemPriceField: UITextField!
    @IBOutlet var itemConditionField: UITextField!
    @IBOutlet var itemDescription: UITextView!
    @IBOutlet var imageButton: UIButton!

    @IBOutlet var doneButton: UIBarButtonItem!
    
    let picker = UIImagePickerController()
    let completeOverlay = OverlayView(type: .complete, text: "Item Donated!")
    
    // data
    var item: Item?
    var groupId: String?
    let priceMinimum = 0.31
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // init manually made Views
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        // give textfield edit change targets
        setupTextField(itemNameField)
        itemNameField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        setupTextField(itemPriceField)
        itemPriceField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        itemPriceField.delegate = self
        setupTextField(itemConditionField)
        itemConditionField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        
        // make textfields dismiss when uiview tapped
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        // assign necessary delegates
        picker.delegate = self
        itemDescription.delegate = self
        
        // fill in default values (if existant)
        itemNameField.text = item?.name
        itemPriceField.text = item?.price
        itemConditionField.text = item?.condition
        itemDescription.text = (item?.itemDescription.characters.count ?? 0) > 0 ? item?.itemDescription : "A Short Description"
        
        // get image
        if let pic = item?.thumbnail {
            let imageData = Data(base64Encoded: pic)
            let image = UIImage(data: imageData!)
            
            imageButton.contentMode = .scaleAspectFit
            imageButton.setBackgroundImage(image, for: .normal)
        }
        
        // start the button as false.
        doneButton.isEnabled = false
    }
    override func viewWillDisappear(_ animated: Bool) {
        dismissKeyboard()
    }
    

    // MARK: Text field/view
    func textFieldDidEndEditing(_ textField: UITextField) {
        let price = Double(textField.text!)!
        if price < 0.31 {
            textField.text = "0.31"
            
            // display alert
            let priceAlert = UIAlertController(title: "Price is too low", message: "The price of your item cannot be less than $0.31", preferredStyle: .alert)
            priceAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(priceAlert, animated: true, completion: nil)
        }
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "A Short Description"
        }
        textChanged(itemNameField)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "A Short Description" {
            textView.text = ""
        }
    }
    
    // MARK: Image picker
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        
        // set the image to the button background.
        let chosenImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        imageButton.contentMode = .scaleAspectFit
        imageButton.setBackgroundImage(chosenImage, for: .normal)
        
        // check if all fields are filled.
        textChanged(itemNameField)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // dismiss
        dismiss(animated: true, completion: nil)
    }

    // MARK: IBAction
    @IBAction func chooseImage(_ sender: UIButton) {
        // dismiss keyboard
        dismissKeyboard()
        
        // prompt for choose or take
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let chooseAction = UIAlertAction(title: "Choose Photo", style: .default) { action in
            // image chooser.
            self.picker.allowsEditing = true
            self.picker.sourceType = .photoLibrary
            self.picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
            self.present(self.picker, animated: true, completion: nil)
        }
        let takeAction = UIAlertAction(title: "Take Photo", style: .default) { action in
            // image taker.
            self.picker.allowsEditing = true
            self.picker.sourceType = .camera
            self.picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .camera)!
            self.present(self.picker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // create action menu
        alertController.addAction(chooseAction)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            alertController.addAction(takeAction)
        }
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func cancelDonate(_ sender: UIBarButtonItem) {
        dismiss(animated: true)
    }
    
    @IBAction func donate(_ sender: UIBarButtonItem) {
        // dismiss keyobard
        dismissKeyboard()
        
        // check that the price is okay
        let dPrice = Double(itemPriceField.text!)!
        if dPrice < priceMinimum {   // 31 cent price minimum due to braintree
            itemPriceField.text = "0.31"
            
            // display alert
            let priceAlert = UIAlertController(title: "Price is too low", message: "The price of your item cannot be less than $0.31", preferredStyle: .alert)
            priceAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(priceAlert, animated: true, completion: nil)
            return
        }
        
        // start animation
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityView)
        self.activityView.startAnimating()
        
        // force unwrap data because they all have to be filled to click done.
        let name = itemNameField.text!
        let price = itemPriceField.text!
        let condition = itemConditionField.text!
        let desc = itemDescription.text!
        
        let imageData = UIImagePNGRepresentation(resizeImage(image: imageButton.currentBackgroundImage!, targetSize: CGSize(width: imageButton.currentBackgroundImage!.size.width * 0.1, height: imageButton.currentBackgroundImage!.size.height * 0.1)))
        let thumbnail = imageData!.base64EncodedString()
        
        print("groupId: \(groupId)")
        // make a post request to add the item to the appropriate group TODO:
        let item = Item(itemId: "", groupId: self.groupId ?? "", ownerId: AppData.user!.userId, name: name, price: price, condition: condition, itemDescription: desc, thumbnail: thumbnail, approved: false)
        HttpRequestManager.post(item: item) { item, response, error in
            // stop animating in main thread
            DispatchQueue.main.async {
                self.activityView.stopAnimating()
                self.navigationItem.rightBarButtonItem = self.doneButton
            }
            
            // see if the item was posted
            let httpResponse = response as? HTTPURLResponse
            switch httpResponse?.statusCode ?? 0 {
            case 200:
                print("ITEM POSTED")
                // dismiss in UI thread
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    let window = UIApplication.shared.keyWindow
                    self.completeOverlay.showAnimatedOverlay(view: window!)
                }
            default:
                DispatchQueue.main.async {
                    // display error message from the server
                    let errorAlert = UIAlertController(title: "Error", message: "Error donating Item.", preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                    errorAlert.addAction(dismissAction)
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: Helper
    func textChanged(_ textField: UITextField) {
        doneButton.isEnabled = shouldEnableDoneButton()
    }
    
    // returns true if all of the text fields are filled out and the image is chosen.
    func shouldEnableDoneButton() -> Bool {
        // check if the fields are empty.
        return (itemNameField.text?.characters.count) ?? 0 > 0 &&
            (itemPriceField.text?.characters.count) ?? 0 > 0 &&
            (Double(itemPriceField.text ?? "0.0") ?? 0.0) > 0.30 &&
            (itemConditionField.text?.characters.count) ?? 0 > 0 &&
            (itemDescription.text?.characters.count) ?? 0 > 0 &&
            imageButton.backgroundImage(for: .normal) != nil
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
        itemNameField.resignFirstResponder()
        itemPriceField.resignFirstResponder()
        itemConditionField.resignFirstResponder()
        itemDescription.resignFirstResponder()
    }
    
    // resize image
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        print("resizing image")
        print("old size: \(size)")
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        print("new size: \(newImage!.size)")
        
        return newImage!
    }
}
