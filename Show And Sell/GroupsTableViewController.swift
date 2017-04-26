//
//  GroupsTableViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 4/24/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit

class GroupsTableViewController: UITableViewController {
    
    // MARK: Properties
    var currentGroup: Group?
    var groups: [Group] = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // apply current group
        currentGroup = AppDelegate.group
        
        // setup refresh control
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        handleRefresh(self.refreshControl)
    }

    // MARK: Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : groups.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Current Group" : "Groups"
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupCell", for: indexPath) as! GroupTableViewCell

        // Configure the cell
        let group = indexPath.section == 0 ? currentGroup : groups[indexPath.row]
        
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
            let group = groups[self.tableView.indexPath(for: sender as! GroupTableViewCell)!.row]
            
            dest.groupId = group.groupId
            dest.name = group.name
            dest.location = group.address
            dest.locationDetail = group.locationDetail
            dest.rating = group.rating
        }
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
}
