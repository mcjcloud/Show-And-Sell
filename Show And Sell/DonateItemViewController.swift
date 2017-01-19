//
//  DontateItemViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/5/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

class DonateItemViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    // UI Elements
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
        picker.delegate = self
        
        itemNameField.delegate = self
        itemPriceField.delegate = self
        itemConditionField.delegate = self
        itemDescription.delegate = self
        
        // fill in default values (if existant)
        itemNameField.text = item?.name
        itemPriceField.text = item?.price
        itemConditionField.text = item?.condition
        itemDescription.text = item?.itemDescription
        
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
        // check if the fields are empty.
        if (itemNameField.text?.characters.count)! > 0, (itemPriceField.text?.characters.count)! > 0, (itemConditionField.text?.characters.count)! > 0, (itemDescription.text?.characters.count)! > 0, imageButton.backgroundImage(for: .normal) != nil {
            doneButton.isEnabled = true
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        // check if the fields are empty.
        if (itemNameField.text?.characters.count)! > 0, (itemPriceField.text?.characters.count)! > 0, (itemConditionField.text?.characters.count)! > 0, (itemDescription.text?.characters.count)! > 0, imageButton.backgroundImage(for: .normal) != nil {
            doneButton.isEnabled = true
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
        if (itemNameField.text?.characters.count)! > 0, (itemPriceField.text?.characters.count)! > 0, (itemConditionField.text?.characters.count)! > 0, (itemDescription.text?.characters.count)! > 0, imageButton.backgroundImage(for: .normal) != nil {
            doneButton.isEnabled = true
        }
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // dismiss
        dismiss(animated: true, completion: nil)
    }

    // MARK IBAction
    @IBAction func chooseImage(_ sender: UIButton) {
        // image chooser.
        picker.allowsEditing = true
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        present(picker, animated: true, completion: nil)
    }
    
}
