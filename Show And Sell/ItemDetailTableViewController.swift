//
//  ItemDetailTableViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 2/16/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit
import Braintree
import BraintreeDropIn

class ItemDetailTableViewController: UITableViewController, UITextViewDelegate {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var conditionLabel: UILabel!
    @IBOutlet var descriptionView: UITextView!
    @IBOutlet var buyButton: UIButton!
    @IBOutlet var bookmarkButton: UIButton!
    @IBOutlet var messagesButton: UIButton!
    
    @IBOutlet var footerView: UIView!
    
    // data to store in above ui elements (all force unwrapped because they are passed in the prepare for segue)
    var thumbnail: UIImage!
    var name: String!
    var price: String!
    var condition: String!
    var desc: String!
    
    var item: Item!
    
    // references
    var previousVC: UIViewController!
    var segue: UIStoryboardSegue!
    
    //var activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var loadOverlay = OverlayView(type: .loading, text: "Loading")
    var tableOffset: CGFloat = -164
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make table start lower to show image
        self.tableView.contentInset = UIEdgeInsetsMake(100, 0, 0, 0)
        
        // corner radius
        self.tableView.layer.cornerRadius = 10
        self.tableView.layer.masksToBounds = true
        
        // setup nav bar
        setupNavBar()
        
        // create UIView to encapsulate UIImage background and set background image.
        let imageView = UIImageView(image: thumbnail)
        if let img = imageView.image {
            let scale: CGFloat = self.view.frame.width / img.size.width
            imageView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: img.size.height * scale)
        }
        imageView.contentMode = .scaleAspectFit
        
        let backView = UIView(frame: self.view.frame)
        backView.addSubview(imageView)
        
        tableView.backgroundView = backView
        
        // set disable status for buttons
        buyButton.setTitleColor(UIColor.gray, for: .disabled)
        bookmarkButton.setTitleColor(UIColor.gray, for: .disabled)
        messagesButton.setTitleColor(UIColor.gray, for: .disabled)
        
        // Do any additional setup after loading the view.
        nameLabel.text = name
        nameLabel.adjustsFontSizeToFitWidth = true
        priceLabel.text = String(format: "$%.02f", Double(price) ?? 0.0)
        conditionLabel.text = condition
        descriptionView.text = desc
        
        // resize descriptionView
        descriptionView.sizeToFit()
        
        // set state of bookmark button
        print("item bookmark: \(item.isBookmarked)")
        bookmarkButton.setTitle(item.isBookmarked! ? "Unbookmark Item" : "Bookmark Item", for: .normal)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // setup nav bar
        setupNavBar()
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        // make navigation bar untransparent again
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        
        // call super method
        super.viewWillDisappear(animated)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? MessagesTableViewController {
            dest.item = item
        }
    }
    
    // MARK: TableView Delegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // calculate height
        let height = nameLabel.frame.height + priceLabel.frame.height + conditionLabel.frame.height + descriptionView.frame.height + buyButton.frame.height + bookmarkButton.frame.height + messagesButton.frame.height + 100
        
        // set footer view to take up remaining space
        footerView.frame = CGRect(origin: footerView.frame.origin, size: CGSize(width: self.view.frame.width, height: self.view.frame.height - tableView.contentSize.height))
        
        return height
    }

    // MARK: ScollView Delegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.navigationController?.navigationBar.alpha = (self.tableView.contentOffset.y) / self.tableOffset
    }

    // MARK: IBAction
    @IBAction func buyItem(_ sender: UIButton) {
        
        // start loading animations
        //self.startLoading()
        loadOverlay.showOverlay(view: self.view)
        
        // Get request token
        HttpRequestManager.paymentToken { t in
            // if there's a token, show the payment dialog
            if let token = t {
                // show the drop in
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
    
    // MARK: Payment
    func showDropIn(token: String) {
        
        // start loading 
        // self.startLoading()
        
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: token, request: request)
        { (controller, result, error) in
            if (error != nil) {
                print("ERROR")
                self.stopLoading()
            }
            else if (result?.isCancelled == true) {
                print("CANCELLED")
                self.stopLoading()
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
        //self.activityView.startAnimating()
        self.loadOverlay.showOverlay(view: self.tableView)
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityView)
        
        // disable buttons
        self.buyButton.isEnabled = false
        self.bookmarkButton.isEnabled = false
        self.messagesButton.isEnabled = false
    }
    
    func stopLoading() {
        // start loading wheel
        self.navigationItem.rightBarButtonItem = nil
        //self.activityView.stopAnimating()
        self.loadOverlay.hideOverlayView()
        
        // disable buttons
        self.buyButton.isEnabled = true
        self.bookmarkButton.isEnabled = true
        self.messagesButton.isEnabled = true
    }
    
    func setupNavBar() {
        //self.navigationController?.hidesBarsOnSwipe = true
        
        // Make nav bar translucent
        let navBar = navigationController?.navigationBar
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()
        navBar?.isTranslucent = true
        
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 2.0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 10.0
        self.navigationController?.navigationBar.layer.shadowOpacity = 1.0
    }
}
