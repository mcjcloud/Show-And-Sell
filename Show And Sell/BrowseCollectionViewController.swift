//
//  BrowseCollectionViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 2/14/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit
import AVFoundation

class BrowseCollectionViewController: UICollectionViewController, StaggeredLayoutDelegate, UISearchResultsUpdating, UISearchControllerDelegate {
    
    @IBOutlet var searchButton: UIBarButtonItem!
    
    // MARK: Properties
    var items: [Item] {
        get {
            return AppData.items ?? [Item]()
        }
        set {
            AppData.items = newValue
        }
    }
    var filteredItems = [Item]()
    var loadInterval = 10
    var canLoadMore = true
    
    var searchController: UISearchController!
    var refreshControl: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // setup search bar
        searchController  = SimpleSearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Filter"
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = false
        
        // enable scrolling at all times
        collectionView?.alwaysBounceVertical = true
        self.collectionView?.panGestureRecognizer.require(toFail: self.navigationController!.interactivePopGestureRecognizer!)

        
        // set delegates
        searchController.delegate = self
        collectionView?.delegate = self
        
        if let layout = collectionView?.collectionViewLayout as? StaggeredLayout {
            layout.delegate = self
        }
        
        // refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl.backgroundColor = UIColor(colorLiteralRed: 0.871, green: 0.788, blue: 0.380, alpha: 1.0) // Gold
        self.collectionView?.addSubview(self.refreshControl)
        
        refreshControl.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        
        // load all items.
        refreshControl.beginRefreshing()
        handleRefresh(self.refreshControl)
    }
    override func viewWillAppear(_ animated: Bool) {
        
        // if there is no data, refresh
        if items.count == 0 {
            refreshControl?.beginRefreshing()
            handleRefresh(self.refreshControl!)
        }
        
        // reload the table data
        self.reloadData(collectionView)
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("PREPARE IN BROWSE")
        if let destination = segue.destination as? ItemDetailTableViewController {
            // get the item to use for details
            if let item = sender as? Item {
                destination.item = item
            }
            else if let cell = sender as? ItemCollectionViewCell {
                let indexPath = (collectionView?.indexPath(for: cell))!
                let item = (searchController.isActive && searchController.searchBar.text != "") ? filteredItems[indexPath.row] : items[indexPath.row]
                
                // assign the data from the item to the fields in the destination view controller
                destination.item = item
            }
        }
        
        // release searchbar
        if searchController.isActive {
            displaySearch(searchButton)
        }
    }

    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // return the size of the item array
        print("number of section: \(items.count)")
        return (searchController.isActive && searchController.searchBar.text != "") ?  filteredItems.count : items.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("cellForItem: \(indexPath.row)")
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCollectionCell", for: indexPath) as! ItemCollectionViewCell
        let item = (searchController.isActive && searchController.searchBar.text != "") ? filteredItems[indexPath.row] : items[indexPath.row]
    
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
    
    //MARK: CollectionView Delegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: update with searchbar
        
        let cell = collectionView.cellForItem(at: indexPath) as! ItemCollectionViewCell
        self.performSegue(withIdentifier: "browseToDetail", sender: cell)
    }
    
    // Implement to load more at bottom.
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        // load more items if we're displaying the last one
        if indexPath.row == items.count - 1 && canLoadMore {
            loadMoreItems()
            canLoadMore = false
        }
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        var lastVisible = false
        if let cView = collectionView {
            for cell in cView.visibleCells {
                if cView.indexPath(for: cell)?.row ?? 0 == items.count - 1 {
                    lastVisible = true
                }
            }
            canLoadMore = !lastVisible
            print("didEndDecelerate, canLoadMore: \(canLoadMore)")
        }
        else {
            canLoadMore = false
        }
    }
    
    // MARK: IBAction
    @IBAction func displaySearch(_ sender: UIBarButtonItem) {
        if self.navigationItem.titleView == searchController.searchBar {
            searchController.searchBar.text = ""
            searchController.isActive = false
            self.navigationItem.titleView = nil
            self.navigationItem.title = "Browse"
        }
        else {
            self.navigationItem.titleView = searchController.searchBar
            searchController.searchBar.becomeFirstResponder()
        }
    }
    
    // MARK: StaggeredLayout Delegate
    func collectionView(_ collectionView: UICollectionView, heightForCellAt indexPath: IndexPath, with width: CGFloat) -> CGFloat {
        return width
    }
    
    // MARK: Helper
    // Handles a drag to refresh
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        print("refreshing")
        // get a list of all approved items in the range
        HttpRequestManager.allApproved(inRange: 0, to: loadInterval) { itemsArray, response, error in
            print("DATA RETURNED")
            
            // set current items to requested items
            self.items = itemsArray
            
            // reload data on the main thread.
            DispatchQueue.main.async {
                self.reloadData(self.collectionView)
                self.refreshControl.endRefreshing()
            }
            print("refresh ending")
        }
    }
    
    func debugRefresh() {
        let item = Item(itemId: "1324", groupId: "1234", ownerId: "1234", name: "Test item", price: "100.00", condition: "New", itemDescription: "New item", thumbnail: "12412412342", approved: true)
        self.items = [item]
        
        // reload data on the main thread.
        DispatchQueue.main.async {
            self.reloadData(self.collectionView)
            self.refreshControl.endRefreshing()
        }
    }
    
    func loadMoreItems() {
        print("LOADING MORE TO BROWSE")
        HttpRequestManager.allApproved(inRange: self.items.count, to: self.items.count + loadInterval) { items, response, error in
            DispatchQueue.main.async {
                self.items += items
                // if more items were loaded, immedietely make canLoadMore true again.
                if items.count > 0 {
                    self.canLoadMore = true
                }
                
                // reload browse
                self.reloadData(self.collectionView)
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func reloadData(_ collectionView: UICollectionView?) {
        //collectionView?.collectionViewLayout.prepare()
        (collectionView?.collectionViewLayout as? StaggeredLayout)?.cache = [UICollectionViewLayoutAttributes]()
        collectionView?.collectionViewLayout.invalidateLayout()
        collectionView?.reloadData()
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
        self.reloadData(self.collectionView)
    }
}
