//
//  FindGroupViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 10/21/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit
import CoreLocation

class FindGroupTableViewController: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate, CLLocationManagerDelegate {
    
    // reference
    var loginVC: LoginViewController!                   // reference to prevent garbage collection
    
    // UI Elements
    @IBOutlet var doneButton: UIBarButtonItem!
    @IBOutlet var addButton: UIBarButtonItem!
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
    var searchedGroups: [Group] = [Group]()
    
    // segue -
    var previousVC: UIViewController?
    
    // location
    var locationManager: CLLocationManager!
    
    // data
    let loadInterval = 10
    let groupRadius: Float = 10.0
    var locationAuth = false
    var coordinates: CLLocationCoordinate2D?
    var overlay = OverlayView(type: .loading, text: nil)

    override func viewDidLoad() {
        print()
        print("finder view did load")
        super.viewDidLoad()

        // set current group
        currentGroup = AppData.group
        oldGroup = currentGroup
        
        if currentGroup == nil {
            doneButton.isEnabled = false
        }
        
        // setup search bar
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.searchBar.delegate = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
        tableView.tableHeaderView = searchController.searchBar
        
        // request location
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        overlay.showOverlay(view: UIApplication.shared.keyWindow!, position: .center)        // display loading while we get location
        
        // get other groups and use activity indicator.
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.backgroundColor = UIColor(colorLiteralRed: 0.871, green: 0.788, blue: 0.380, alpha: 1.0) // Gold
        self.refreshControl!.addTarget(self, action: #selector(handleRefresh(_:)), for: .valueChanged)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        // when the view appears, check if the addButton should be enabled
        addButton.isEnabled = shouldEnableAddButton()
    }
    

    // MARK: Tableview
    override func numberOfSections(in tableView: UITableView) -> Int {
        return currentGroup != nil ? 2 : 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.numberOfSections > 1 {
            if searchController.isActive && searchController.searchBar.text! != "" {
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
                cell.checkBox.image = UIImage(named: "green-check")
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
        if currentGroup != nil && indexPath.section == 0 {
            print("current group section selected")
            tableView.reloadData()
            return
        }
        
        // make the selected cell the current group, reload the table.
        currentGroup = (searchController.isActive && searchController.searchBar.text! != "") ? filteredGroups[indexPath.row] : groups[indexPath.row]
        AppData.group = currentGroup
        self.tableView.reloadData()
    }
    
    // MARK: Location
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("did change authorization")
        if status == .authorizedWhenInUse {
            if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) && CLLocationManager.isRangingAvailable() {
                // location is working
                locationAuth = true
                locationManager.startUpdatingLocation()
            }
        }
        else {
            overlay.hideOverlayView()
            locationAuth = false
        }
    }
    
    // when the location is recieved, update the global variable
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last?.coordinate
        self.coordinates = location
        manager.stopUpdatingLocation()
        
        // stop loading
        overlay.hideOverlayView()
        locationAuth = true
        
        // start refresh manually
        self.refreshControl!.beginRefreshing()
        handleRefresh(self.refreshControl!)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // an error occurred getting location. Use non-location group loading.
        // stop loading
        overlay.hideOverlayView()
        locationAuth = false
        
        // start refresh
        self.refreshControl!.beginRefreshing()
        handleRefresh(self.refreshControl!)
    }
    
    // MARK: IBAction
    @IBAction func donePressed(_ sender: UIBarButtonItem) {
        print("done pressed")
        print("previousVC: \(self.previousVC)")
        // determine where to go
        if let _ = previousVC as? LoginViewController {
            // the last screen was the login or create, so go to tabs
            if currentGroup != oldGroup {
                // clear the data
                AppDelegate.tabVC?.clearBrowseData()
            }
            self.performSegue(withIdentifier: "finderToTabs", sender: self)
        }
        else if let _ = previousVC as? IntroViewController {
            // the last screen was the login or create, so go to tabs
            if currentGroup != oldGroup {
                // clear the data
                AppDelegate.tabVC?.clearBrowseData()
            }
            self.performSegue(withIdentifier: "finderToTabs", sender: self)
        }
        else {
            // dismiss to whatever you were previously at
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    // function to handle the data refreshing
    func handleRefresh(_ refreshControl: UIRefreshControl) {
        if locationAuth {
            if let loc = coordinates {
                print("getting by location")
                print("lat: \(loc.latitude) long: \(loc.longitude)")
                HttpRequestManager.groups(inRadius: groupRadius, fromLatitude: loc.latitude, longitude: loc.longitude) { groups, response, error in
                    self.groups = groups
                    
                    DispatchQueue.main.async {
                        self.refreshControl!.endRefreshing()
                        self.tableView.reloadData()
                    }
                }
                return
            }
        }
        
        print("getting all groups")
        HttpRequestManager.groups { groups, response, error in
            print("error: \(error)")
            
            self.groups = groups
            
            // update the UI in the main thread
            DispatchQueue.main.async {
                self.refreshControl!.endRefreshing()
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: Navigation
    @IBAction func unwindToFinder(_ segue: UIStoryboardSegue) {
        print("finder unwind")
    }
    
    
    // MARK: Searchbar
    func filterGroups(for searchText: String) {
        filteredGroups = groups.filter {
            return $0.name.lowercased().contains(searchText.lowercased())
        }
    }
    func updateSearchResults(for searchController: UISearchController) {
        //filterGroups(for: searchController.searchBar.text!)
        //tableView.reloadData()
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // make search request
        HttpRequestManager.groups(matching: searchBar.text ?? "") { groups, response, error in
            print("searched: \(groups)")
            self.filteredGroups = groups
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: Helper
    
    // returns if true if there is the user doesn't have a group
    func shouldEnableAddButton() -> Bool {
        return AppData.myGroup == nil
    }
}
