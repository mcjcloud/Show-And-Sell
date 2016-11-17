//
//  DonateViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/5/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

class DonateViewController: UIViewController {
    @IBOutlet var donateButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        // set button titles for states
        // using viewWillAppear because it will be called each time the view comes on the screen.
        donateButton.setTitle("Please choose a group in settings", for: .disabled)
        donateButton.setTitle("Donate Item", for: .normal)
        
        // if there is no group set, false, else true
        donateButton.isEnabled = AppDelegate.save.group != "" && AppDelegate.save.group != nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Navigation
    @IBAction func cancelDonate(segue: UIStoryboardSegue) {
        // cancelled the donate action
        
    }
    @IBAction func donateItem(segue: UIStoryboardSegue) {
        // all fields filled out, donate item.
        let source = segue.source as! DonateItemViewController
        
        // force unwrap data because they all have to be filled to click done.
        let name = source.itemNameField.text!
        let price = source.itemPriceField.text!
        let condition = source.itemConditionField.text!
        let desc = source.itemDescription.text!
        
        let imageData = UIImagePNGRepresentation(resizeImage(image: source.imageButton.currentBackgroundImage!, targetSize: CGSize(width: 250, height: 250)))
        let thumbnail = imageData!.base64EncodedString()
        
        // make a post request to add the item to the appropriate group TODO:
        let item = Item(itemId: "", groupId: AppDelegate.save.group!, ownerId: AppDelegate.user!.userId, name: name, price: price, condition: condition, itemDescription: desc, thumbnail: thumbnail, isBookmarked: false)
        HttpRequestManager.postItem(with: item) { item, response, error in
            print("ITEM POST COMPLETION")
            if error != nil {
                print("ERROR: \(error)")
            }
            else {
                if let _ = item {
                    print("Item successfully posted")
                }
            }
        }
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
