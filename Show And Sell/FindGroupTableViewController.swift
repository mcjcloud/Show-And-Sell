//
//  FindGroupViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 10/21/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

class FindGroupTableViewController: UITableViewController, UISearchResultsUpdating {
    
    // reference
    var loginVC: LoginViewController!                   // reference to prevent garbage collection
    
    // UI Elements
    @IBOutlet var doneButton: UIBarButtonItem!
    var searchController: UISearchController!
    
    var oldGroup: Group?
    var currentGroup: Group? {
        willSet {
            oldGroup = currentGroup
        }
        didSet {
            print("done button enabled: \(doneButton)")
            doneButton.isEnabled = currentGroup != nil
        }
    }
    var groups: [Group] = [Group]()
    var filteredGroups: [Group] = [Group]()
    
    // segue -
    var previousViewController: SettingsTableViewController!

    override func viewDidLoad() {
        print()
        print("finder view did load")
        super.viewDidLoad()

        // set current group
        currentGroup = AppDelegate.group
        oldGroup = currentGroup
        
        if currentGroup == nil {
            doneButton.isEnabled = false
        }
        
        // setup search bar
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        // get other groups and use activity indicator.
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl!.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        
        // start refresh manually
        self.refreshControl!.beginRefreshing()
        handleRefresh(self.refreshControl!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: Tableview
    override func numberOfSections(in tableView: UITableView) -> Int {
        return currentGroup != nil ? 2 : 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.numberOfSections > 1 {
            if (searchController.isActive && searchController.searchBar.text! != "") {
                return section == 0 ? 1 : filteredGroups.count
            }
            else {
                return section == 0 ? 1 : groups.count
            }
        }
        else {
            return (searchController.isActive && searchController.searchBar.text! != "") ? filteredGroups.count : groups.count
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // if there's more than one section, titles are "Current Group" and "Groups", respectively
        if tableView.numberOfSections > 1 {
            return section == 0 ? "Current Group" : "Groups"
        }
        // if there's only one section, it's just "Groups"
        else {
            return "Groups"
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> FindGroupTableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "findGroupCell") as! FindGroupTableViewCell
        cell.checkBox.image = nil
        
        if tableView.numberOfSections > 1 {                             // if the table view has more than one section
            if indexPath.section == 0 {                                     // if its the first row.
                cell.nameLabel.text = currentGroup?.name
                cell.checkBox.image = UIImage(named: "checkmark")
            }
            else {
                if (searchController.isActive && searchController.searchBar.text! != "") {
                    cell.nameLabel.text = filteredGroups[indexPath.row].name
                    cell.checkBox.image = nil
                }
                else {
                    cell.nameLabel.text = groups[indexPath.row].name
                    cell.checkBox.image = nil
                }
            }
        }
        else {      // if there is only one section.
            cell.nameLabel.text = groups[indexPath.row].name
            cell.checkBox.image = nil
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // return if you select the current group
        
        if tableView.headerView(forSection: indexPath.section)?.textLabel?.text == "Current Group" {
            tableView.reloadData()
            return
        }
        
        // make the selected cell the current group, reload the table.
        currentGroup = (searchController.isActive && searchController.searchBar.text! != "") ? filteredGroups[indexPath.row] : groups[indexPath.row]
        AppDelegate.group = currentGroup
        self.tableView.reloadData()
    }
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        print("done pressed")
        // go to browse
        if previousViewController != nil {
            self.dismiss(animated: true, completion: {})
        }
        else {
            if currentGroup == oldGroup {
                print("unwind to browse")
                self.performSegue(withIdentifier: "unwindToBrowse", sender: self)
            }
            else {
                
                print("segue finderToTabs")
                print("prev: \(previousViewController != nil)")
                self.performSegue(withIdentifier: "finderToTabs", sender: self)
            }
        }
    }
    
    // function to handle the data refreshing
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        HttpRequestManager.getGroups() { groups, response, error in
            print("error: \(error)")
            
            if let groupArray = groups {
                print("groupArray: \(groupArray)")
                self.groups = groupArray
            }
            else {
                
            }
            
            // update the UI in the main thread
            DispatchQueue.main.async {
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination as? SSTabBarViewController {
            dest.loginVC = self.loginVC
        }
    }
    
    // MARK: Searchbar
    func filterGroups(for searchText: String) {
        filteredGroups = groups.filter {
            return $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    func updateSearchResults(for searchController: UISearchController) {
        filterGroups(for: searchController.searchBar.text!)
        tableView.reloadData()
    }
}
