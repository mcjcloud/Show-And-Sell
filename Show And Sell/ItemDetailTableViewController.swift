//
//  ItemDetailTableViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 2/16/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit
import Social
import Braintree
import BraintreeDropIn

class ItemDetailTableViewController: UITableViewController, UITextViewDelegate {

    // MARK: UI Properties
    var nameLabel: UILabel?
    var groupLink: UIButton?
    var priceLabel: UILabel?
    var conditionLabel: UILabel?
    var descriptionView: UITextView?
    var buttonStack: UIStackView?
    var buyButton: UIButton?
    var bookmarkButton: UIButton?
    var shareButton: UIButton?
    
    var imageView: UIImageView?
    
    var commentButton: OverlayView?
    
    // MARK: Properties
    var item: Item!
    var messages = [Message]()
    var group: Group?
    
    // blur effect for image
    var effect: UIBlurEffect!
    var blurView: UIVisualEffectView!
    // references
    var previousVC: UIViewController!
    var segue: UIStoryboardSegue!
    
    //var activityView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    var loadOverlay = OverlayView(type: .loading, text: "Loading")
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentButton = OverlayView(image: UIImage(named: "comment")!)
        commentButton?.setOnClick(postMessage)
        
        // activity indicator
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 60, height: 60)                     // setup activity indicator
        activityIndicator.hidesWhenStopped = true
        
        let imageData = Data(base64Encoded: item.thumbnail)
        let image = imageData != nil ? UIImage(data: imageData!) : UIImage(named: "noimage")
        let headerView = ParallaxHeaderView.parallaxHeaderView(with: image, for: CGSize(width: self.tableView.frame.width, height: 250)) as! ParallaxHeaderView
        self.tableView.tableHeaderView = headerView
        
        
        // set group button text
        groupLink?.setTitle("Getting group", for: .disabled)
        groupLink?.isEnabled = false
        
        // set state of bookmark button
        bookmarkButton?.setImage(UIImage(named: item.isBookmarked! ? "unbookmark_button" : "bookmark_button"), for: .normal)
        
        // update the items group variable
        getGroup()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
 
        // update messages
        handleRefresh()
        
        // show comment button
        commentButton?.showOverlay(view: UIApplication.shared.keyWindow!, position: .bottomRight)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        self.navigationController?.navigationBar.shadowImage = nil
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.view.backgroundColor = UIColor(colorLiteralRed: 0.298, green: 0.686, blue: 0.322, alpha: 1.0)
        
        commentButton?.hideOverlayView()
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? MessagesTableViewController {
            dest.item = item
        }
        else if let dest = segue.destination as? ImageDisplayViewController {
            dest.image = imageView?.image
        }
        else if let dest = segue.destination as? GroupDetailViewController {
            if let group = group {
                dest.name = group.name
                dest.location = group.address
                dest.locationDetail = group.locationDetail
                dest.rating = group.rating
            }
        }
    }
    
    @IBAction func unwindToItemDetail(segue: UIStoryboardSegue) {
        // do nothing
    }
    
    // MARK: TableView Delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count > 0 ? messages.count + 2 : 2
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "topCell") as! ItemDetailTableViewCell
            
            self.nameLabel = cell.nameLabel
            self.groupLink = cell.groupLink
            self.priceLabel = cell.priceLabel
            self.conditionLabel = cell.conditionLabel
            self.descriptionView = cell.descriptionView
            self.buttonStack = cell.buttonStack
            self.buyButton = cell.buyButton
            self.bookmarkButton = cell.bookmarkButton
            self.shareButton = cell.shareButton
            
            // set actions
            buyButton?.addTarget(self, action: #selector(buyItem(_:)), for: .touchUpInside)
            bookmarkButton?.addTarget(self, action: #selector(bookmarkItem(_:)), for: .touchUpInside)
            
            // set state of bookmark button
            bookmarkButton?.setImage(UIImage(named: item.isBookmarked! ? "unbookmark_button" : "bookmark_button"), for: .normal)
            
            // assign data
            nameLabel?.text = item.name
            nameLabel?.adjustsFontSizeToFitWidth = true
            priceLabel?.text = String(format: "$%.02f", Double(item.price) ?? 0.0)
            conditionLabel?.text = item.condition
            descriptionView?.text = item.itemDescription
            
            // resize descriptionView
            descriptionView?.sizeToFit()
            
            return cell
        }
        else if indexPath.row == 1 && messages.count == 0 {
            // setup table view cell with activity indicator
            let cell = UITableViewCell()
            activityIndicator.center = cell.center
            cell.addSubview(activityIndicator)
            cell.isUserInteractionEnabled = false
            
            return cell
        }
        else if indexPath.row == (messages.count > 0 ? messages.count + 2 : 2) - 1 {
            let cell = UITableViewCell()
            cell.isUserInteractionEnabled = false
            return cell
        }
        else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! MessageTableViewCell
            
            // get the messages sorted by the date, at the given index.
            let message = messages.sorted(by: {
                let formatter = DateFormatter()
                formatter.dateFormat = "M/d/yyyy hh:mm:ss a"
                
                let date1 = formatter.date(from: $0.datePosted)
                let date2 = formatter.date(from: $1.datePosted)
                
                return date1! < date2!
            })[indexPath.row - 1]
            
            // Configure the cell...
            cell.nameLabel.text = message.posterName
            cell.messageLabel.text = message.body
            cell.selectionStyle = .none
            
            // customize based on who sent.
            if message.posterId == (AppDelegate.user?.userId ?? "") {
                cell.backgroundColor = UIColor(colorLiteralRed: 0.298, green: 0.686, blue: 0.322, alpha: 1.0)    // Green
                cell.nameLabel.textAlignment = .right
                cell.messageLabel.textAlignment = .right
            }
            else if message.posterId == item.ownerId {
                cell.backgroundColor = UIColor(colorLiteralRed: 0.871, green: 0.788, blue: 0.38, alpha: 1.0)     // Gold
                cell.nameLabel.textAlignment = .left
                cell.messageLabel.textAlignment = .left
            }
            else if message.posterId == message.adminId {
                cell.backgroundColor = UIColor(colorLiteralRed: 0.871, green: 0.788, blue: 0.38, alpha: 1.0)     // Gold
                cell.nameLabel.textAlignment = .left
                cell.messageLabel.textAlignment = .left
            }
            else {
                cell.backgroundColor = UIColor.white
                cell.nameLabel.textAlignment = .left
                cell.messageLabel.textAlignment = .left
            }
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var height: CGFloat = 0.0
        if indexPath.row == 0 {
            // calculate height
            let uiParts: [UIView?] = [nameLabel, groupLink, priceLabel, conditionLabel, descriptionView, buttonStack]
            for uiPart in uiParts {
                height += uiPart?.frame.height ?? 0
            }
            height += 120
        }
        else {
            height = 63.0
        }
        
        return height
    }
    
    // MARK: ScollView Delegate
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // update ParallaxHeader
        let header = self.tableView.tableHeaderView as! ParallaxHeaderView
        header.layoutHeaderView(forScrollOffset: scrollView.contentOffset)
        
        self.tableView.tableHeaderView = header
    }

    // MARK: IBAction
    @IBAction func showGroup(_ sender: UIButton) {
        // segue to group detail
        self.performSegue(withIdentifier: "detailToGroup", sender: self)
    }
    func buyItem(_ sender: UIButton) {
        
        // start loading animations
        //self.startLoading()
        loadOverlay.showOverlay(view: UIApplication.shared.keyWindow!, position: .center)
        
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
    
    func bookmarkItem(_ sender: UIButton) {
        // bookmark/unbookmark item
        if item.isBookmarked! {
            // set state of bookmark button
            bookmarkButton?.setImage(UIImage(named: "bookmark_button"), for: .normal)            // send bookmark delete request
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
            // set state of bookmark button
            bookmarkButton?.setImage(UIImage(named: "unbookmark_button"), for: .normal)
            // make bookmark post request.
            HttpRequestManager.post(bookmarkForUserWithId: AppDelegate.user?.userId ?? "", itemId: item.itemId) { bookmarkData, response, error in
                print("post bookmark response returned")
                AppDelegate.bookmarks?[self.item] = bookmarkData.bookmarkId
            }
        }
    }
    
    func shareItem(_ sender: UIButton) {
        // twitter sharing
        if SLComposeViewController.isAvailable(forServiceType: SLServiceTypeTwitter) {
            let tweetSheet = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            //tweetSheet
            tweetSheet?.setInitialText("Check out \"\(item.name)\" on Show & Sell!")
            tweetSheet?.add(URL(string: "ich-showandsell.gear.host/?itemId=\(item.itemId)"))
            self.present(tweetSheet!, animated: true, completion: nil)
        }
        else {
            let errorAlert = UIAlertController(title: "Not Available", message: "Make sure Twitter is installed and you are signed in.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(errorAlert, animated: true, completion: nil)
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
        self.loadOverlay.showOverlay(view: UIApplication.shared.keyWindow!, position: .center)
        //self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.activityView)
        
        // disable buttons
        self.buyButton?.isEnabled = false
        self.bookmarkButton?.isEnabled = false    }
    
    func stopLoading() {
        // start loading wheel
        self.navigationItem.rightBarButtonItem = nil
        //self.activityView.stopAnimating()
        self.loadOverlay.hideOverlayView()
        
        // disable buttons
        self.buyButton?.isEnabled = true
        self.bookmarkButton?.isEnabled = true
    }
    
    func displayFullImage() {
        print("displaying image")
        let imageVC = storyboard?.instantiateViewController(withIdentifier: "imageVC") as! ImageDisplayViewController
        //imageVC.image = imageView?.image
        self.present(imageVC, animated: true)
    }
    
    func handleRefresh() {
        self.activityIndicator.startAnimating()
        HttpRequestManager.messages(forItemId: item.itemId) { messages, response, error in
            self.messages = messages
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.tableView.reloadData()
            }
        }
    }
    
    func postMessage() {
        
        let inputController = UIAlertController(title: "Post Message", message: "What would you like to say?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let doneAction = UIAlertAction(title: "Post", style: .default) { inputAction in
            // post message
            if let text = inputController.textFields?[0].text, text.characters.count > 0 {
                HttpRequestManager.post(messageWithPosterId: AppDelegate.user?.userId ?? "", posterPassword: AppDelegate.user?.password ?? "", itemId: self.item.itemId, text: text) { message, response, error in
                    print("Message posted")
                    self.handleRefresh()
                }
            }
            else {
                inputController.title = "Text cannot be empty"
                self.present(inputController, animated: true, completion: nil)
            }
        }
        
        inputController.addTextField { field in
            field.autocapitalizationType = .sentences
        }
        inputController.addAction(cancelAction)
        inputController.addAction(doneAction)
        
        present(inputController, animated: true, completion: nil)
    }
    
    func getGroup() {
        HttpRequestManager.group(withId: item.groupId) { group, response, error in
            if let group = group {
                self.group = group
                DispatchQueue.main.async {
                    self.groupLink?.setTitle(group.name, for: .normal)
                    self.groupLink?.isEnabled = true
                }
            }
        }
    }
}
