//
//  ItemDetailViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/5/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//
//  UIViewController implementation to show display the details of an Item to a user
//

import UIKit
import BraintreeDropIn
import Braintree

class ItemDetailViewController: UIViewController {

    // UI Elements
    @IBOutlet var image: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var conditionLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    
    @IBOutlet var buyButton: UIButton!
    @IBOutlet var bookmarkButton: UIButton!
    @IBOutlet var messagesButton: UIButton!
    
    var activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    // data to store in above ui elements (all force unwrapped because they are passed in the prepare for segue)
    var thumbnail: UIImage!
    var name: String!
    var price: String!
    var condition: String!
    var desc: String!
    
    // data
    var item: Item!
    
    var previousVC: UIViewController!
    var segue: UIStoryboardSegue!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set disable status for buttons
        buyButton.setTitleColor(UIColor.gray, for: .disabled)
        bookmarkButton.setTitleColor(UIColor.gray, for: .disabled)
        messagesButton.setTitleColor(UIColor.gray, for: .disabled)

        // Do any additional setup after loading the view.
        image.image = thumbnail
        nameLabel.text = name
        priceLabel.text = String(format: "Price: $%.02f", Double(price) ?? 0.0)
        conditionLabel.text = condition
        descriptionTextView.text = desc
     
        // set state of bookmark button
        print("item bookmark: \(item.isBookmarked)")
        bookmarkButton.setTitle(item.isBookmarked! ? "Unbookmark Item" : "Bookmark Item", for: .normal)
        
        // edit navigation bar
        self.navigationItem.title = name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBAction
    @IBAction func buyItem(_ sender: UIButton) {
        
        // start loading animations
        self.startLoading()
        
        // Get request token
        HttpRequestManager.paymentToken { t in
            // if there's a token, show the payment dialog
            if let token = t {
                self.showDropIn(token: token)
            }
            else {
                // TODO: display error getting token
                print("error getting token")
                
                // stop animating and display message
                DispatchQueue.main.async {
                    self.stopLoading()
                    
                    // Display Message
                    let tokenErrorMessage = UIAlertController(title: "Error getting token", message: "Unable to get authorization from server.", preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .default, handler: nil)
                    tokenErrorMessage.addAction(dismissAction)
                    self.present(tokenErrorMessage, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func bookmarkItem(_ sender: UIButton) {
        // bookmark/unbookmark item
        if item.isBookmarked! {
            bookmarkButton.setTitle("Bookmark Item", for: .normal)
            // send bookmark delete request
            print("sending bookmark delete")
            print("bookmarks: \(AppDelegate.bookmarks)")
            if let bookmarks = AppDelegate.bookmarks, let bookmarkId = bookmarks[item] {
                print("got bookmarks from AppDelegate")
                HttpRequestManager.delete(bookmarkWithId: bookmarkId) { bookmarkData, response, error in
                    print("delete bookmark response returned")
                }
                let _ = AppDelegate.bookmarks?.removeValue(forKey: item)
            }
        }
        else {
            bookmarkButton.setTitle("Unbookmark Item", for: .normal)
            // make bookmark post request.
            HttpRequestManager.post(bookmarkForUserWithId: AppDelegate.user?.userId ?? "", itemId: item.itemId) { bookmarkData, response, error in
                print("post bookmark response returned")
                AppDelegate.bookmarks?[self.item] = bookmarkData.bookmarkId
            }
        }
    }
    
    @IBAction func showMessages(_ sender: UIButton) {
        performSegue(withIdentifier: "detailToMessages", sender: sender)
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? MessagesTableViewController {
            dest.item = item
        }
    }
    
    // MARK: Payment
    func showDropIn(token: String) {
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: token, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
            }
            else if (result?.isCancelled == true) {
                print("CANCELLED")
            }
            else if let result = result {
                
                // make purchase request
                HttpRequestManager.buy(itemWithId: self.item.itemId,
                                       userId: AppDelegate.user!.userId,
                                       password: AppDelegate.user!.password,
                                       paymentDetails: (token: token, nonce: result.paymentMethod?.nonce ?? "", amount: Double(self.item.price) ?? 0.0))
                { paymentInfo, response, error in
                    
                    // remove item references
                    if let dest = self.previousVC as? BrowseCollectionViewController {
                        let index = dest.items.index(where: { e in e.itemId == self.item.itemId })
                        if let i = index {
                            dest.items.remove(at: i)
                        }
                    }
                    else if let dest = self.previousVC as? BookmarksTableViewController {
                        dest.bookmarks.removeValue(forKey: self.item)
                    }
                    
                    // pop view controller in main thread
                    DispatchQueue.main.async {
                        self.stopLoading()
                        let _ = self.navigationController?.popViewController(animated: true)
                    }
                    
                }
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    // MARK: Helper
    func startLoading() {
        // start loading wheel
        self.activityView.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityView)
        
        // disable buttons
        self.buyButton.isEnabled = false
        self.bookmarkButton.isEnabled = false
        self.messagesButton.isEnabled = false
    }
    
    func stopLoading() {
        // start loading wheel
        self.navigationItem.rightBarButtonItem = nil
        self.activityView.stopAnimating()
        
        // disable buttons
        self.buyButton.isEnabled = true
        self.bookmarkButton.isEnabled = true
        self.messagesButton.isEnabled = true
    }
}
