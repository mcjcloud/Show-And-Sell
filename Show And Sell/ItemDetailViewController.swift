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
    
    @IBOutlet var buyButton: UIButton!
    @IBOutlet var bookmarkButton: UIButton!
    @IBOutlet var messagesButton: UIButton!
    
    // data to store in above ui elements (all force unwrapped because they are passed in the prepare for segue)
    var thumbnail: UIImage!
    var name: String!
    var price: String!
    var condition: String!
    var desc: String!
    
    // data
    var item: Item!
    var previousVC: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
        // Buy item 
        HttpRequestManager.buy(itemId: item?.itemId ?? "", userId: AppDelegate.user?.userId ?? "", password: AppDelegate.user?.password ?? "") { item, response, error in
            print("made BUY request with status code: \((response as? HTTPURLResponse)?.statusCode)")
        }
        
        var unwindSegue: UIStoryboardSegue?
        if let prev = previousVC as? BrowseTableViewController {
            unwindSegue = UIStoryboardSegue(identifier: "itemDetail", source: prev, destination: self)
        }
        else if let prev = previousVC as? BookmarksTableViewController {
            unwindSegue = UIStoryboardSegue(identifier: "bookmarkDetail", source: prev, destination: self)
        }
        if let segue = unwindSegue {
            unwind(for: segue, towardsViewController: previousVC)
        }
        else {
            print("nil segue")
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
                HttpRequestManager.deleteBookmark(bookmarkId: bookmarkId) { bookmarkData, response, error in
                    print("delete bookmark response returned")
                }
                let _ = AppDelegate.bookmarks?.removeValue(forKey: item)
            }
        }
        else {
            bookmarkButton.setTitle("Unbookmark Item", for: .normal)
            // make bookmark post request.
            HttpRequestManager.postBookmark(userId: AppDelegate.user?.userId ?? "", itemId: item.itemId) { bookmarkData, response, error in
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
        else if let dest = segue.destination as? BrowseTableViewController {
            let index = dest.items.index(where: { e in e.itemId == self.item.itemId })
            if let i = index {
                dest.items.remove(at: i)
            }
        }
        else if let dest = segue.destination as? BookmarksTableViewController {
            dest.bookmarks.removeValue(forKey: self.item)
        }
    }
}
