//
//  BookmarksViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/5/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

class BookmarksTableViewController: UITableViewController {
    
    var bookmarks = [Item: String]() {                          // the AppDel bookmarks or an empty array.
        didSet {
            bookmarkItems = bookmarks.keys.sorted(by: { return $0.name < $1.name })
        }
    }
    var bookmarkItems = [Item]()
    
    lazy var slideUpTransitionDelegate = SlideUpPresentationManager()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // set navigation bar
        navigationItem.title = "Bookmarks"
        
        // refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = UIColor(colorLiteralRed: 0.871, green: 0.788, blue: 0.380, alpha: 1.0) // Gold
        refreshControl!.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        
        // load all bookmarks.
        refreshControl?.beginRefreshing()
        handleRefresh(self.refreshControl!)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        // if the tab is reclicked or showed after being left, reload the data.
        // update the data dictionary
        self.bookmarks = AppDelegate.bookmarks ?? [Item: String]()
        
        tableView.reloadData()
    }
    

    // MARK: - Navigation
    
     // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // if going to item detail
        if let destination = segue.destination as? ItemDetailTableViewController {
            // prepare to go to detail view
            let cell = sender as! ItemTableViewCell
            
            let item = bookmarkItems[(self.tableView.indexPath(for: cell)?.row)!]
            
            // transition
            destination.transitioningDelegate = slideUpTransitionDelegate
            destination.modalPresentationStyle = .custom
            
            // assign the data from the item to the fields in the destination view controller
            destination.item = item
        }
        // else, going to settings
    }
 
    // MARK: Table View Delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // RETURN the number of rows, based on how many items there are to browse.
        
        print()
        print("num of sections in row: \(bookmarks.count)")
        return bookmarks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ItemTableViewCell {
        // build the cell
        let item = bookmarkItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "bookmarkCell") as! ItemTableViewCell
     
        // assign data
        cell.item = item
        cell.itemTitle.adjustsFontSizeToFitWidth = true
        cell.itemTitle.textAlignment = .left
        cell.itemPrice.adjustsFontSizeToFitWidth = true
        cell.itemPrice.textAlignment = .right
        
        cell.itemTitle.text = item.name
        cell.itemPrice.text = String(format: "$%.02f", Double(item.price) ?? 0.0)   // cast the string to double, and format.
        cell.itemCondition.text = item.condition
        
        let imageData = Data(base64Encoded: item.thumbnail)
        if let data = imageData {
            cell.itemImage.image = UIImage(data: data)
        }
        else {
            cell.itemImage.image = UIImage(named: "noimage")
        }
        
        return cell
    }
    // when a cell is selected, go to its details
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.visibleCells[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "bookmarkToDetail", sender: cell)
    }
    
    // MARK: Refresh
    
    // Handles a drag to refresh
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        print()
        print("refreshing")
        // get a list of all items (for now)
        HttpRequestManager.bookmarks(forUserWithId: AppDelegate.user!.userId, password: AppDelegate.user!.password) { bookmarks, response, error in
            print("DATA RETURNED")
            
            // set current items to requested items
            if let b = bookmarks {
                self.bookmarks = b
                AppDelegate.bookmarks = b
            }
            
            // reload data on the main thread.
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
            print("refresh ending")
        }
    }
}
