//
//  GroupsTableViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 4/24/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit

class GroupsTableViewController: UITableViewController, UISearchResultsUpdating, UISearchControllerDelegate {
    
    // MARK: UI Properties
    @IBOutlet var searchButton: UIBarButtonItem!
    @IBOutlet var createGroupButton: UIBarButtonItem!
    
    // MARK: Properties
    var currentGroup: Group? {
        return AppData.group
    }
    var groups: [Group] = [Group]()
    var filteredGroups = [Group]()
    
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // setup refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        self.refreshControl?.backgroundColor = UIColor(colorLiteralRed: 0.871, green: 0.788, blue: 0.380, alpha: 1.0) // Gold
        handleRefresh(self.refreshControl)
        
        // setup search bar
        searchController  = SimpleSearchController(searchResultsController: nil)
        searchController.searchBar.placeholder = "Filter"
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        
        // enable/disable create group button
        self.createGroupButton.isEnabled = createGroupShouldEnable()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.createGroupButton.isEnabled = createGroupShouldEnable()
        self.handleRefresh(self.refreshControl)
    }

    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return AppData.group != nil ? 2 : 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.numberOfSections(in: tableView) == 2 {
            return section == 0 ? 1 :
            (self.searchController.isActive && self.searchController.searchBar.text! != "") ? filteredGroups.count : groups.count
        }
        else {
            return (self.searchController.isActive && self.searchController.searchBar.text! != "") ? filteredGroups.count : groups.count
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if self.numberOfSections(in: tableView) == 2 {
            return section == 0 ? "Favorite Group" : "Groups"
        }
        else {
            return "Groups"
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupTableViewCell

        // Configure the cell
        var group: Group!
        if self.numberOfSections(in: tableView) == 2 && indexPath.section == 0 {
            group = currentGroup
        }
        else {
            group = (self.searchController.isActive && self.searchController.searchBar.text! != "") ? filteredGroups[indexPath.row] : groups[indexPath.row]
        }
        
        cell.nameLabel.text = group?.name
        cell.addressLabel.text = group?.address
        cell.ratingLabel.text = String(format: "Rating: %.1f", group?.rating ?? 0.0)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        self.performSegue(withIdentifier: "groupsToGroup", sender: cell)
    }

    // MARK: Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? GroupDetailViewController {
            let indexPath = self.tableView.indexPath(for: sender as! GroupTableViewCell)!
            var group: Group!
            if self.numberOfSections(in: tableView) == 2 && indexPath.section == 0 {
                group = currentGroup!
            }
            else {
                group = self.groups[indexPath.row]
            }
            
            dest.group = group
            dest.groupId = group.groupId
            dest.name = group.name
            dest.location = group.address
            dest.locationDetail = group.locationDetail
            dest.rating = group.rating
        }
    }
    
    // MARK: IBAction
    @IBAction func createGroup(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "groupsToCreateGroup", sender: self)
    }
    
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
    
    // MARK: Filtering search results.
    
    func filterGroups(for searchText: String) {
        filteredGroups = groups.filter {
            return $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    func updateSearchResults(for searchController: UISearchController) {
        filterGroups(for: searchController.searchBar.text!)
        self.tableView.reloadData()
    }
    
    // MARK: Helper
    func handleRefresh(_ refreshControl: UIRefreshControl!) {
        HttpRequestManager.groups { groups, response, error in
            if error == nil {
                self.groups = groups
                
                DispatchQueue.main.async {
                    self.refreshControl?.endRefreshing()
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func createGroupShouldEnable() -> Bool {
        return AppData.myGroup == nil
    }
}
