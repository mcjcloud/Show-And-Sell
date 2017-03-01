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

class DonateItemViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // UI Elements
    var activityView: UIActivityIndicatorView!
    @IBOutlet var itemNameField: UITextField!
    @IBOutlet var itemPriceField: UITextField!
    @IBOutlet var itemConditionField: UITextField!
    @IBOutlet var itemDescription: UITextView!
    @IBOutlet var imageButton: UIButton!

    @IBOutlet var doneButton: UIBarButtonItem!
    
    let picker = UIImagePickerController()
    
    // data
    var item: Item?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // init manually made Views
        activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        // give textfield edit change targets
        itemNameField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        itemPriceField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        itemConditionField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: Text field/view
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
    
    @IBAction func donate(_ sender: UIBarButtonItem) {
        // start animation
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityView)
        self.activityView.startAnimating()
        
        // force unwrap data because they all have to be filled to click done.
        let name = itemNameField.text!
        let price = itemPriceField.text!
        let condition = itemConditionField.text!
        let desc = itemDescription.text!
        
        let imageData = UIImagePNGRepresentation(resizeImage(image: imageButton.currentBackgroundImage!, targetSize: CGSize(width: 250, height: 250)))
        let thumbnail = imageData!.base64EncodedString()
        
        // make a post request to add the item to the appropriate group TODO:
        let item = Item(itemId: "", groupId: AppDelegate.group!.groupId, ownerId: AppDelegate.user!.userId, name: name, price: price, condition: condition, itemDescription: desc, thumbnail: thumbnail, approved: false)
        HttpRequestManager.post(item: item) { item, response, error in
            // stop animating in main thread
            DispatchQueue.main.async {
                self.activityView.stopAnimating()
                self.navigationItem.rightBarButtonItem = self.doneButton
            }
            
            // see if the item was posted
            let httpResponse = response as! HTTPURLResponse
            switch httpResponse.statusCode {
            case 200:
                // TODO: display success message.
                print("ITEM POSTED")
            default:
                DispatchQueue.main.async {
                    // display error message from the server
                    let errorAlert = UIAlertController(title: "Error", message: "\(httpResponse)", preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                    errorAlert.addAction(dismissAction)
                    self.present(errorAlert, animated: true, completion: nil)
                }
            }
            
            // dismiss in UI thread
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
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
        return (itemNameField.text?.characters.count)! > 0 &&
            (itemPriceField.text?.characters.count)! > 0 &&
            (itemConditionField.text?.characters.count)! > 0 &&
            (itemDescription.text?.characters.count)! > 0 &&
            imageButton.backgroundImage(for: .normal) != nil
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
