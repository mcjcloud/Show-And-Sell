//
//  ManageGroupTableViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 11/28/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

extension Array {
    func elements(where predicate: (Element) -> Bool) -> Array {
        var list = [Element]()
        for elem in self {
            if predicate(elem) {
                list.append(elem)
            }
        }
        
        return list
    }
}

class ManageGroupTableViewController: UITableViewController, UISearchResultsUpdating {

    var searchController: UISearchController!
    
    // properties
    var items = [Item]()
    var filteredItems = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Manage Group"

        // setup search bar
        searchController  = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        // refresh control
        self.refreshControl = UIRefreshControl()
        refreshControl!.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        
        // load all items.
        refreshControl?.beginRefreshing()
        self.refreshControl?.backgroundColor = UIColor(colorLiteralRed: 0.663, green: 0.886, blue: 0.678, alpha: 0.7957) // Green
        handleRefresh(self.refreshControl!)
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // 1 for unapproved items, the other for approved items.
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Unapproved" : "Approved"
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return (searchController.isActive && searchController.searchBar.text != "") ?  filteredItems.count : items.count
        
        let approved = (searchController.isActive && searchController.searchBar.text != "") ? filteredItems.elements(where: { e in e.approved == true }) : items.elements(where: { e in e.approved == true })
        let unapproved = (searchController.isActive && searchController.searchBar.text != "") ? filteredItems.elements(where: { e in e.approved == false }) : items.elements(where: { e in e.approved == false })
        
        // if it's the top section, and there are 2 sections
        if section == 0 {
            return unapproved.count
        }
        else {  // if section == 1
            return approved.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure the cell...

        let cell = tableView.dequeueReusableCell(withIdentifier: "manageCell") as! ItemTableViewCell
        
        let approved = (searchController.isActive && searchController.searchBar.text != "") ? filteredItems.elements(where: { e in e.approved == true }) : items.elements(where: { e in e.approved == true })
        let unapproved = (searchController.isActive && searchController.searchBar.text != "") ? filteredItems.elements(where: { e in e.approved == false }) : items.elements(where: { e in e.approved == false })
        
        let item = indexPath.section == 0 ? unapproved[indexPath.row] : approved[indexPath.row]
        
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
        performSegue(withIdentifier: "manageToEdit", sender: cell)
    }
    // make table view cell respond to swipe
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // TODO: implement if necessary
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // Implement actions.
        let section = indexPath.section
        
        var actions = [UITableViewRowAction]()
        if section == 0 {   // unapproved
            let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { action, indexPath in
                
                // get the Item selected
                let cell = tableView.cellForRow(at: indexPath) as! ItemTableViewCell
                let item = self.items.first(where: { e in e.name == cell.itemTitle.text })
                
                // delete the Item
                HttpRequestManager.delete(itemWithId: item?.itemId ?? "", password: AppDelegate.user?.password ?? "") { item, response, error in
                    print("Item delete response: \((response as? HTTPURLResponse)?.statusCode)")
                }
                tableView.reloadData()
            }
            let approveAction = UITableViewRowAction(style: .normal, title: "Approve") { action, indexPath in
                
                // get the Item selected
                let cell = tableView.cellForRow(at: indexPath) as! ItemTableViewCell
                let item = self.items.first(where: { e in e.name == cell.itemTitle.text })
                
                // PUT the item with approved: true
                if let i = item {
                    i.approved = true
                    HttpRequestManager.put(item: i, itemId: i.itemId, adminPassword: AppDelegate.user?.password ?? "") { item, response, error in
                        print("Item update response: \((response as? HTTPURLResponse)?.statusCode)")
                    }
                }
                tableView.reloadData()
            }
            
            actions.append(approveAction)
            actions.append(deleteAction)
        }
        else {              // approved
            let unapproveAction = UITableViewRowAction(style: .destructive, title: "Unapprove") { action, indexPath in
                
                // get the Item selected
                let cell = tableView.cellForRow(at: indexPath) as! ItemTableViewCell
                let item = self.items.first(where: { e in e.name == cell.itemTitle.text })
                
                // PUT the item with approved: false
                if let i = item {
                    i.approved = false
                    HttpRequestManager.put(item: i, itemId: i.itemId, adminPassword: AppDelegate.user?.password ?? "") { item, response, error in
                        print("Item update response: \((response as? HTTPURLResponse)?.statusCode)")
                    }
                }
                tableView.reloadData()
            }
            
            actions.append(unapproveAction)
        }
        
        // return the array
        return actions
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let source = sender as! ItemTableViewCell
        let item = items.first(where: { e in e.name == source.itemTitle.text })
        let destination = segue.destination as! DonateItemViewController
        
        // assign data from cell.
        destination.item = item
        /*
        destination.imageButton.contentMode = .scaleAspectFit
        destination.imageButton.setBackgroundImage(source.itemImage.image, for: .normal)
        
        destination.itemNameField.text = item?.name
        destination.itemPriceField.text = item?.price
        destination.itemDescription.text = item?.itemDescription
        destination.itemConditionField.text = item?.condition
        */
    }
    
    @IBAction func updateItem(segue: UIStoryboardSegue) {
        // send update request to server
        // all fields filled out, donate item.
        let source = segue.source as! DonateItemViewController
        
        // force unwrap data because they all have to be filled to click done.
        let item = source.item!
        
        item.name = source.itemNameField.text!
        item.price = source.itemPriceField.text!
        item.condition = source.itemConditionField.text!
        item.itemDescription = source.itemDescription.text!
        
        let imageData = UIImagePNGRepresentation(resizeImage(image: source.imageButton.currentBackgroundImage!, targetSize: CGSize(width: 250, height: 250)))
        item.thumbnail = imageData!.base64EncodedString()
        
        // make a post request to add the item to the appropriate group TODO:
        //let item = Item(itemId: "", groupId: AppDelegate.save.group!, ownerId: AppDelegate.user!.userId, name: name, price: price, condition: condition, itemDescription: desc, thumbnail: thumbnail, approved: false)
        HttpRequestManager.put(item: item, itemId: item.itemId, adminPassword: AppDelegate.user?.password ?? "") { item, response, error in
            print("ITEM PUT COMPLETION")
            if error != nil {
                print("ERROR: \(error)")
            }
            else {
                if let _ = item {
                    print("Item successfully updated")
                }
            }
        }
    }
    
    @IBAction func cancelUpdate(segue: UIStoryboardSegue) {
        // Do nothing.
    }

    // MARK: Refresh
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        print()
        print("refreshing")
        // get a list of all items (for now)
        // TODO: get items based on owned group.
        HttpRequestManager.items(withGroupId: AppDelegate.myGroup!.groupId) { itemsArray, response, error in
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
    }
    
    // MARK: SearchBar
    func updateSearchResults(for searchController: UISearchController) {
        filterItems(for: searchController.searchBar.text!)
        tableView.reloadData()
    }
    func filterItems(for searchText: String) {
        filteredItems = items.filter {
            return $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    
    // resize image
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        print("resizing image")
        print("old size: \(size)")
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        print("new size: \(newImage!.size)")
        
        return newImage!
    }

}
