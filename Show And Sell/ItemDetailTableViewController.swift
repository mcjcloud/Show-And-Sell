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
    
    // struct for states
    struct ItemDetailVCStates {
        var shouldRestoreNavBar = true
        var shouldShowActivityIndicator = true
    }

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
    var states = ItemDetailVCStates()
    
    // blur effect for image
    var effect: UIBlurEffect!
    var blurView: UIVisualEffectView!
    
    // loading indicators
    var loadOverlay = OverlayView(type: .loading, text: nil)
    let commentActivityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentButton = OverlayView(image: UIImage(named: "comment")!)
        commentButton?.setOnClick(postMessage)
        
        // activity indicator
        commentActivityIndicator.frame = CGRect(x: 0, y: 0, width: 60, height: 60)                     // setup activity indicator
        commentActivityIndicator.hidesWhenStopped = true
        
        let imageData = Data(base64Encoded: item.thumbnail)
        let image = imageData != nil ? UIImage(data: imageData!) : UIImage(named: "noimage")
        let headerView = ParallaxHeaderView.parallaxHeaderView(with: image, for: CGSize(width: self.tableView.frame.width, height: 250)) as! ParallaxHeaderView
        self.tableView.tableHeaderView = headerView
        
        let touchRecognizer = UITapGestureRecognizer(target: self, action: #selector(displayFullImage))
        headerView.addGestureRecognizer(touchRecognizer)
        
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
        showCommentButton()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        if self.states.shouldRestoreNavBar {
            self.navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
            self.navigationController?.navigationBar.shadowImage = nil
            self.navigationController?.navigationBar.isTranslucent = false
            self.navigationController?.view.backgroundColor = UIColor(colorLiteralRed: 0.298, green: 0.686, blue: 0.322, alpha: 1.0)
        }
        
        hideCommentButton()
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ImageDisplayViewController {
            dest.image = imageView?.image
            print("segue to image display")
        }
        else if let dest = segue.destination as? GroupDetailViewController {
            if let group = group {
                // assign destination data
                dest.group = group
                dest.groupId = group.groupId
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
        return messages.count > 0 ? messages.count + 1 : 2
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
            shareButton?.addTarget(self, action: #selector(shareItem(_:)), for: .touchUpInside)
            
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
            if self.states.shouldShowActivityIndicator {
                // setup table view cell with activity indicator
                let cell = UITableViewCell()
                cell.frame.size = CGSize(width: self.view.frame.width, height: self.tableView(tableView, heightForRowAt: indexPath))
                commentActivityIndicator.center = cell.center
                cell.addSubview(commentActivityIndicator)
                cell.isUserInteractionEnabled = false
                
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "noComments")
                return cell!
            }
        }
        else if indexPath.row == (messages.count > 0 ? messages.count + 2 : 2) - 1 {    // the last cell
            return UITableViewCell()
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
            cell.messageLabel.numberOfLines = 0
            cell.messageLabel.lineBreakMode = .byWordWrapping
            cell.selectionStyle = .none
            
            // customize based on who sent.
            if message.posterId == (AppData.user?.userId ?? "") {
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
        if indexPath.row == 0 { // first cell (item details)
            // calculate height
            let uiParts: [UIView?] = [nameLabel, groupLink, priceLabel, conditionLabel, descriptionView, buttonStack]
            for uiPart in uiParts {
                height += uiPart?.frame.height ?? 0
            }
            height += 120
        }
        else if indexPath.row == (messages.count > 0 ? messages.count + 2 : 2) - 1 {    // the last cell
            height = 63.0
        }
        else {  // comment cell
            // get the messages sorted by the date, at the given index.
            let message = messages.sorted(by: {
                let formatter = DateFormatter()
                formatter.dateFormat = "M/d/yyyy hh:mm:ss a"
                
                let date1 = formatter.date(from: $0.datePosted)
                let date2 = formatter.date(from: $1.datePosted)
                
                return date1! < date2!
            })[indexPath.row - 1]
            
            // calculate cell height based on text
            height = 34.0 + heightForView(text: message.body, font: UIFont.systemFont(ofSize: 17.0), width: self.view.frame.width - 16.0)
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
        loadOverlay.showOverlay(view: self.view, position: .center)
        
        // Get request token
        HttpRequestManager.paymentToken { t in
            // if there's a token, show the payment dialog
            if let token = t {
                // show the drop in
                self.showDropIn(token: token)
            }
            else {
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
            if let bookmarks = AppData.bookmarks, let bookmarkId = bookmarks[item] {
                HttpRequestManager.delete(bookmarkWithId: bookmarkId, completion: nil)
                let _ = AppData.bookmarks?.removeValue(forKey: item)
            }
        }
        else {
            // set state of bookmark button
            bookmarkButton?.setImage(UIImage(named: "unbookmark_button"), for: .normal)
            // make bookmark post request.
            HttpRequestManager.post(bookmarkForUserWithId: AppData.user?.userId ?? "", itemId: item.itemId) { bookmarkData, response, error in
                print("post bookmark response returned")
                AppData.bookmarks?[self.item] = bookmarkData.bookmarkId
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
    
    // MARK: Payment
    func showDropIn(token: String) {
        
        // start loading 
        // self.startLoading()
        
        let request =  BTDropInRequest()
        let dropIn = BTDropInController(authorization: token, request: request) { (controller, result, error) in
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
                                       userId: AppData.user!.userId,
                                       password: AppData.user!.password,
                                       paymentDetails: (token: token, nonce: result.paymentMethod?.nonce ?? "", amount: Double(self.item.price) ?? 0.0))
                { paymentInfo, response, error in
                    
                    // remove item references
                    let item = AppData.items?.first(where: { e in e.itemId == self.item.itemId })
                    let index = AppData.items?.index(of: item!)
                    if let i = index {
                        AppData.items?.remove(at: i)
                    }
                    
                    // pop view controller in main thread
                    DispatchQueue.main.async {
                        self.stopLoading()
                        
                        let successOverlay = OverlayView(type: .complete, text: "Item Purchased")
                        successOverlay.showAnimatedOverlay(view: UIApplication.shared.keyWindow!)
                        
                        let _ = self.navigationController?.popViewController(animated: true)
                    }
                    
                }
            }
            controller.dismiss(animated: true, completion: nil)
        }
        self.present(dropIn!, animated: true, completion: nil)
    }
    
    
    // MARK: Helper
    
    func showCommentButton() {
        commentButton?.showOverlay(view: UIApplication.shared.keyWindow!, position: .bottomRight)
    }
    func hideCommentButton() {
        commentButton?.hideOverlayView()
    }
    
    func startLoading() {
        // start loading wheel
        self.loadOverlay.showOverlay(view: UIApplication.shared.keyWindow!, position: .center)
        
        // disable buttons
        hideCommentButton()
        self.buyButton?.isEnabled = false
        self.bookmarkButton?.isEnabled = false    }
    
    func stopLoading() {
        // start loading wheel
        self.loadOverlay.hideOverlayView()
        
        // enable buttons
        showCommentButton()
        self.buyButton?.isEnabled = true
        self.bookmarkButton?.isEnabled = true
    }
    
    func displayFullImage() {
        self.states.shouldRestoreNavBar = false
        print("displaying image")
        let imageVC = storyboard?.instantiateViewController(withIdentifier: "imageVC") as! ImageDisplayViewController
        imageVC.image = (self.tableView.tableHeaderView as! ParallaxHeaderView).headerImage
        self.present(imageVC, animated: true) {
            self.states.shouldRestoreNavBar = true
        }
    }
    
    func postMessage() {
        
        let inputController = UIAlertController(title: "Post Message", message: "What would you like to say?", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive, handler: nil)
        let doneAction = UIAlertAction(title: "Post", style: .default) { inputAction in
            // post message
            if let text = inputController.textFields?[0].text, text.characters.count > 0 {
                HttpRequestManager.post(messageWithPosterId: AppData.user?.userId ?? "", posterPassword: AppData.user?.password ?? "", itemId: self.item.itemId, text: text) { message, response, error in
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
    
    func handleRefresh() {
        self.states.shouldShowActivityIndicator = true
        self.tableView.reloadData()
        self.commentActivityIndicator.startAnimating()
        HttpRequestManager.messages(forItemId: item.itemId) { messages, response, error in
            self.messages = messages
            
            DispatchQueue.main.async {
                self.commentActivityIndicator.stopAnimating()
                self.states.shouldShowActivityIndicator = false
                self.tableView.reloadData()
            }
        }
    }
    
    func getGroup() {
        HttpRequestManager.group(withId: item.groupId) { group, response, error in
            if let group = group {
                self.group = group
                DispatchQueue.main.async {
                    self.groupLink?.setTitle("\(group.name) >", for: .normal)
                    self.groupLink?.isEnabled = true
                }
            }
        }
    }
    
    func heightForView(text:String, font: UIFont, width: CGFloat) -> CGFloat{
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: CGFloat.greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
    }
}
