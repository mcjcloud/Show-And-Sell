//
//  ItemDetailViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/5/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

class ItemDetailViewController: UIViewController {

    // UI Elements
    @IBOutlet var image: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var priceLabel: UILabel!
    @IBOutlet var conditionLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var bookmarkButton: UIButton!
    
    // data to store in above ui elements (all force unwrapped because they are passed in the prepare for segue)
    var thumbnail: UIImage!
    var name: String!
    var price: String!
    var condition: String!
    var desc: String!
    
    // data
    var item: Item!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        image.image = thumbnail
        nameLabel.text = name
        priceLabel.text = String(format: "Price: $%.02f", Double(price) ?? 0.0)
        conditionLabel.text = condition
        descriptionTextView.text = desc
     
        // set state of bookmark button
        bookmarkButton.setTitle(item.isBookmarked ? "Unbookmark Item" : "Bookmark Item", for: .normal)
        
        // edit navigation bar
        self.navigationItem.title = name
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBAction
    @IBAction func bookmarkItem(_ sender: UIButton) {
        // bookmark/unbookmark item
        item.isBookmarked = !item.isBookmarked
        bookmarkButton.setTitle(item.isBookmarked ? "Unbookmark Item" : "Bookmark Item", for: .normal)
    }
    
}
