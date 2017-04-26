//
//  GroupViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/20/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit
import AVFoundation

class GroupDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, StaggeredLayoutDelegate {
    
    // MARK: UI Properties
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var locationDetailLabel: UILabel!
    @IBOutlet var donateButton: UIButton!
    @IBOutlet var giveMoneyButton: UIButton!
    @IBOutlet var makeDefaultButton: UIButton!
    @IBOutlet var rateButton: UIButton!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var itemsCollectionView: UICollectionView!
    
    // MARK: Properties
    var groupId: String?
    var name: String?
    var location: String?
    var locationDetail: String?
    var rating: Float?
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
        self.ratingLabel.text = String(format: "Rating: %.1f", self.rating ?? 0)//"Rating: \(rating != nil ? rating! : 0.0)"
        
        // setup collection view
        itemsCollectionView?.alwaysBounceVertical = true
        itemsCollectionView.dataSource = self
        itemsCollectionView.delegate = self
        if let layout = itemsCollectionView?.collectionViewLayout as? StaggeredLayout {
            layout.delegate = self
        }
        
        // load this groups approved items.
        loadItems()
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? ItemDetailTableViewController {
            dest.item = items[self.itemsCollectionView.indexPath(for: sender as! ItemCollectionViewCell)!.row]
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
        cell.layer.cornerRadius = 10.0
        cell.backgroundColor = UIColor.black
        // convert the image from encoded string to an image.
        let imageData = Data(base64Encoded: item.thumbnail)
        if let data = imageData {
            cell.itemImageView.image = UIImage(data: data)
        }
        else {
            cell.itemImageView.image = UIImage(named: "noimage")
        }
        cell.priceLabel.text = String(format: "$%.02f ", Double(item.price) ?? 0.0)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // navigate to item
        let cell = collectionView.cellForItem(at: indexPath)
        
        self.performSegue(withIdentifier: "groupToItem", sender: cell)
    }

    // MARK: StaggeredLayout Delegate
    func collectionView(_ collectionView: UICollectionView, heightForCellAt indexPath: IndexPath, with width: CGFloat) -> CGFloat {
        //print("height for cell: \(indexPath.row)")
        let item = items[indexPath.row]
        
        let imageData = Data(base64Encoded: item.thumbnail)
        let image: UIImage!
        if let data = imageData {
            image = UIImage(data: data)
        }
        else {
            image = UIImage(named: "noimage")
        }
        
        // adjust size and return the height
        let boundingRect =  CGRect(x: 0, y: 0, width: width, height: CGFloat(MAXFLOAT))
        let rect  = AVMakeRect(aspectRatio: image.size, insideRect: boundingRect)
        return rect.size.height
    }
    
    // MARK: IBAction
    @IBAction func donateItem(_ sender: UIButton) {
        self.performSegue(withIdentifier: "groupToDonate", sender: self)
    }
    @IBAction func donateMoney(_ sender: UIButton) {
        
    }
    @IBAction func setAsDefault(_ sender: UIButton) {
        
    }
    @IBAction func rateGroup(_ sender: UIButton) {
        let rateView = RateXIBView(parentView: UIApplication.shared.keyWindow!)
        rateView.show()
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
