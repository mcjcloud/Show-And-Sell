//
//  BrowseViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/5/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

class BrowseTableViewController: UITableViewController, UISearchResultsUpdating {
    
    // properties
    var items = [Item]()
    var filteredItems = [Item]()
    
    var searchController: UISearchController!
    
    let loadInterval = 10

    override func viewDidLoad() {
        print("VIEW DID LOAD BROWSE CONTROLLER")
        super.viewDidLoad()
        
        // setup search bar
        searchController  = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar

        // Do any additional setup after loading the view.
        print("View did load")
        
        // refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = UIColor(colorLiteralRed: 0.663, green: 0.886, blue: 0.678, alpha: 0.7957) // Green
        refreshControl!.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        
        // load all items.
        refreshControl?.beginRefreshing()
        handleRefresh(self.refreshControl!)
    }
    override func viewWillAppear(_ animated: Bool) {
        // if there is no data, refresh
        if items.count == 0 {
            refreshControl?.beginRefreshing()
            handleRefresh(self.refreshControl!)
        }
        
        // reload the table data
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // going to item detail
        if let destination = segue.destination as? ItemDetailViewController {
            // prepare to go to detail view
            let cell = sender as! ItemTableViewCell
            
            // select item based on weather or not search is active
            let item = (searchController.isActive && searchController.searchBar.text! != "") ? filteredItems[(tableView.indexPath(for: cell)?.row)!] : items[(tableView.indexPath(for: cell)?.row)!]
            // get the item obj from AppDelegate to fix bug in ItemDetailVC where Unbookmark doesn't work.
            let appDelItem = AppDelegate.bookmarks?.first(where: { (k, v) in k.itemId == item.itemId })?.key
            
            // assign the data from the item to the fields in the destination view controller
            destination.name = item.name
            destination.price = item.price
            destination.condition = item.condition
            destination.desc = item.itemDescription
            destination.item = appDelItem ?? item
            destination.previousVC = self
            destination.segue = segue
            
            let imageData = Data(base64Encoded: item.thumbnail)
            if let data = imageData {
                destination.thumbnail = UIImage(data: data)
            }
            else {
                destination.thumbnail = UIImage(named: "noimage")
            }
        }
        // otherwise, going to settings
    }
    // handle unwind here.
    @IBAction func unwindToBrowse(segue: UIStoryboardSegue) {
        print("unwind to browse")
    }
    
    // MARK: TableView delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // RETURN the number of rows, based on how many items there are to browse.
        print("number or rows")
        print(searchController)
        print(filteredItems)
        print(items)
        
        return (searchController.isActive && searchController.searchBar.text != "") ?  filteredItems.count : items.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> ItemTableViewCell {
        // return a cell based on array of items.
        print("Table cell for index")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "itemCell") as! ItemTableViewCell
        
        
        let item = (searchController.isActive && searchController.searchBar.text != "") ? filteredItems[indexPath.row] : items[indexPath.row]
        
        // assign data from item to fields of cell
        cell.itemTitle.text = item.name
        cell.itemPrice.text = String(format: "$%.02f", Double(item.price) ?? 0.0)   // cast the string to double, and format.
        cell.itemCondition.text = item.condition
        
        // convert the image from encoded string to an image.
        let imageData = Data(base64Encoded: item.thumbnail)
        if let data = imageData {
            cell.itemImage.image = UIImage(data: data)
        }
        else {
            cell.itemImage.image = UIImage(named: "noimage")
        }
        
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // segue to the view displaying the item.
        let cell = tableView.cellForRow(at: indexPath)
        performSegue(withIdentifier: "itemDetails", sender: cell)
    }
    /* reimplement for load interval at a time.
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // check if its the last tableViewCell
        if indexPath.row == items.count - 1 {
            // load next indecies
            loadNext()
        }
    }
     */
    
    // Handles a drag to refresh
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        print("refreshing")
        // get a list of all items (for now)
        HttpRequestManager.approvedItems(withGroupId: AppDelegate.group?.groupId ?? "") { itemsArray, response, error in
            print("DATA RETURNED")
            
            // set current items to requested items
            self.items = itemsArray
            
            // reload data on the main thread.
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.refreshControl?.endRefreshing()
            }
            print("refresh ending")
        }
        /*
        HttpRequestManager.approvedItems(with: AppDelegate.group?.groupId ?? "", inRange: items.count, to: items.count + loadInterval) { items, response, error in
            self.items += items
            
            DispatchQueue.main.async {
                // update GUI
                self.tableView.reloadData()
            }
        }
        */
    }
    func loadNext() {
        HttpRequestManager.approvedItems(withGroupId: AppDelegate.group?.groupId ?? "", inRange: items.count, to: items.count + loadInterval) { items, response, error in
            self.items += items
            
            DispatchQueue.main.async {
                // update GUI
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: Filtering search results.
    func filterItems(for searchText: String) {
        filteredItems = items.filter {
            return $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    func updateSearchResults(for searchController: UISearchController) {
        print("UPDATE SEARCH RESULTS")
        filterItems(for: searchController.searchBar.text!)
        tableView.reloadData()
    }
}
