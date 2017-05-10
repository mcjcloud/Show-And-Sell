//
//  GroupViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/20/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit
import AVFoundation
import Braintree
import BraintreeDropIn

class GroupDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, StaggeredLayoutDelegate, RateXIBViewDelegate {
    
    // MARK: UI Properties
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var locationDetailLabel: UILabel!
    @IBOutlet var buttonStack: UIStackView!
    @IBOutlet var donateButton: UIButton!
    @IBOutlet var giveMoneyButton: UIButton!
    @IBOutlet var makeDefaultButton: UIButton!
    @IBOutlet var rateButton: UIButton!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var itemsCollectionView: UICollectionView!
    
    // MARK: Properties
    var group: Group!
    
    var groupId: String?
    var name: String?
    var location: String?
    var locationDetail: String?
    var rating: Float?
    var myRating: Int?
    var items = [Item]()
    
    var overlay = OverlayView(type: .loading, text: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set title
        self.navigationItem.title = "Group Detail"

        // assign passed in properties
        self.nameLabel.text = name
        self.locationLabel.adjustsFontSizeToFitWidth = true
        self.locationLabel.text = location
        self.locationDetailLabel.text = locationDetail
        self.ratingLabel.text = String(format: "Rating: %.1f", self.rating ?? 0)
        
        // setup collection view
        itemsCollectionView?.alwaysBounceVertical = true
        itemsCollectionView.dataSource = self
        itemsCollectionView.delegate = self
        if let layout = itemsCollectionView?.collectionViewLayout as? StaggeredLayout {
            layout.delegate = self
        }
        
        // set default button
        self.makeDefaultButton.setImage(UIImage(named: AppData.group?.groupId ?? "" == self.groupId ? "default" : "make_default"), for: .normal)
        
        // get the users current rating for the group (if any)
        HttpRequestManager.rating(forGroupId: self.groupId ?? "", andUserId: AppData.user?.userId ?? "") { rating, response, error in
            self.myRating = rating
        }
        
        // load this groups approved items.
        loadItems()
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.overlay.hideOverlayView()
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ItemDetailTableViewController {
            dest.item = items[self.itemsCollectionView.indexPath(for: sender as! ItemCollectionViewCell)!.row]
        }
        else if let dest = segue.destination.childViewControllers[0] as? DonateItemViewController {
            print("giving the item donate the group id")
            dest.groupId = self.groupId
        }
    }
    
    // MARK: UICollectionView
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return item count
        return items.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("making item cell")
        let cell = itemsCollectionView.dequeueReusableCell(withReuseIdentifier: "itemCollectionCell", for: indexPath) as! ItemCollectionViewCell
        let item = items[indexPath.row]
        
        // Configure the cell
        cell.backgroundColor = UIColor.black
        // convert the image from encoded string to an image.
        let imageData = Data(base64Encoded: item.thumbnail)
        if let data = imageData {
            cell.itemImageView.image = UIImage(data: data)
        }
        else {
            cell.itemImageView.image = UIImage(named: "noimage")
        }
        cell.priceLabel.text = String(format: "   $%.02f ", Double(item.price) ?? 0.0)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // navigate to item
        let cell = collectionView.cellForItem(at: indexPath)
        
        self.performSegue(withIdentifier: "groupToItem", sender: cell)
    }

    // MARK: StaggeredLayout Delegate
    func collectionView(_ collectionView: UICollectionView, heightForCellAt indexPath: IndexPath, with width: CGFloat) -> CGFloat {
        return width
    }
    
    // MARK: RateXIBView Delegate
    func rateXIBView(didSubmitRating rating: Int) {
        // make HTTP reqeust to rate group
        HttpRequestManager.rateGroup(withId: groupId ?? "", rating: rating, userId: AppData.user?.userId ?? "", password: AppData.user?.password ?? "") { rating, response, error in
            print("response code: \((response as? HTTPURLResponse)?.statusCode)")
            if let rating = rating {
                DispatchQueue.main.async {
                    print("rating: \(rating)")
                    self.rating = rating
                    self.ratingLabel.text = String(format: "Rating: %.1f", self.rating ?? 0)
                    
                    if let group = AppData.group, group.groupId == self.groupId {
                        group.rating = rating
                    }
                }
            }
        }
    }
    
    // MARK: IBAction
    @IBAction func donateItem(_ sender: UIButton) {
        self.overlay.showOverlay(view: self.view, position: .center)
        self.performSegue(withIdentifier: "groupToDonate", sender: self)
    }
    @IBAction func donateMoney(_ sender: UIButton) {
        
        // start loading
        let overlay = OverlayView(type: .loading, text: nil)
        overlay.showOverlay(view: self.view, position: .center)
        
        // request Token
        HttpRequestManager.paymentToken { token in
            
            if token == nil {
                DispatchQueue.main.async {
                    let tokenErrorAlert = UIAlertController(title: "Token Error", message: "Couldn't get request token.", preferredStyle: .alert)
                    tokenErrorAlert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
                    self.present(tokenErrorAlert, animated: true, completion: nil)
                    overlay.hideOverlayView()
                }
                return
            }
            
            // show alert
            let donateAlert = UIAlertController(title: "Donate Money", message: "Enter amount:", preferredStyle: .alert)
            donateAlert.addTextField { textField in
                textField.keyboardType = .numberPad
            }
            
            let donateAction = UIAlertAction(title: "Donate", style: .default) { action in
                // check input
                if let text = donateAlert.textFields?[0].text, let amount = Double(text) {
                    let dropInRequest = BTDropInRequest()
                    let dropIn = BTDropInController(authorization: token!, request: dropInRequest) { (controller, result, error) in
                        if (error != nil) {
                            print("ERROR")
                            overlay.hideOverlayView()
                        }
                        else if (result?.isCancelled == true) {
                            print("CANCELLED")
                            overlay.hideOverlayView()
                        }
                        else if let result = result {
                            // make HTTP request
                            HttpRequestManager.donateToGroup(withId: self.groupId ?? "", userId: AppData.user?.userId ?? "", password: AppData.user?.password ?? "", paymentDetails: (token: token!, nonce: result.paymentMethod?.nonce ?? "", amount: amount)) { result, response, error in
                                print("donate status code: \((response as? HTTPURLResponse)?.statusCode)")
                                let success = (response as? HTTPURLResponse)?.statusCode == 200
                                let responseOverlay = OverlayView(type: success ? .complete : .failed, text: success ? "Donation Made" : "Donation Failed")
                                DispatchQueue.main.async {
                                    overlay.hideOverlayView()
                                    responseOverlay.showAnimatedOverlay(view: UIApplication.shared.keyWindow!)
                                }
                            }
                        }
                        controller.dismiss(animated: true, completion: nil)
                    }
                    self.present(dropIn!, animated: true, completion: nil)
                    
                }
                else {
                    let errorAlert = UIAlertController(title: "Empty Text", message: "Please enter a value.", preferredStyle: .alert)
                    let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
                    errorAlert.addAction(dismissAction)
                    
                    DispatchQueue.main.async {
                        self.present(errorAlert, animated: true, completion: nil)
                    }
                    return
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive) { action in
                DispatchQueue.main.async {
                    overlay.hideOverlayView()
                }
            }
            
            donateAlert.addAction(donateAction)
            donateAlert.addAction(cancelAction)
            
            DispatchQueue.main.async {
                self.present(donateAlert, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func setAsDefault(_ sender: UIButton) {
        AppData.group = self.group
        
        // change button
        self.makeDefaultButton.setImage(UIImage(named: AppData.group?.groupId ?? "" == self.groupId ? "default" : "make_default"), for: .normal)
    }
    @IBAction func rateGroup(_ sender: UIButton) {
        let rateView = RateXIBView(parentView: UIApplication.shared.keyWindow!)
        rateView.delegate = self
        rateView.show(rating: self.myRating ?? 0)
    }
    
    // MARK: Helper
    func loadItems() {
        self.overlay.showOverlay(view: self.itemsCollectionView, position: .center)
        HttpRequestManager.approvedItems(withGroupId: groupId ?? "") { items, response, error in
            self.items = items
            DispatchQueue.main.async {
                self.overlay.hideOverlayView()
                self.itemsCollectionView.reloadData()
            }
        }
    }
}
