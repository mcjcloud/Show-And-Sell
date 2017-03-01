//
//  SettingsViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 10/11/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate {
    @IBOutlet var manageCell: UITableViewCell!

    @IBOutlet var arrowView: UIView!
    @IBOutlet var arrowImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? LoginViewController {
            // prepare for the login screen.
            destination.autoLogin = false
        }
        else if let destination = segue.destination as? FindGroupTableViewController {
            destination.navigationItem.rightBarButtonItem = destination.navigationItem.leftBarButtonItem
            destination.navigationItem.leftBarButtonItem = nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch(indexPath.row) {
            case 0:     // Choose Group
                self.performSegue(withIdentifier: "settingsToFinder", sender: self)
            case 1:     // Manage Group
                if let _ = AppDelegate.myGroup {
                    print("my group: \(AppDelegate.myGroup?.name)")
                    self.performSegue(withIdentifier: "settingsToManage", sender: self)
                }
                else {
                    let alertController = UIAlertController(title: "Group not found", message: "A group with your user was not found.", preferredStyle: .alert)
                    
                    let createAction = UIAlertAction(title: "Create", style: .default) { action in
                        // go to Create Group
                        self.performSegue(withIdentifier: "settingsToCreateGroup", sender: self)
                    }
                    let reloadAction = UIAlertAction(title: "Reload", style: .default) { action in
                        print("reloading myGroup")
                        DispatchQueue.main.async {
                            
                            self.manageCell.isUserInteractionEnabled = false
                        }
                        // get myGroup
                        HttpRequestManager.group(withAdminId: AppDelegate.user!.userId) { group, response, error in
                            print("got myGroup")
                            AppDelegate.myGroup = group
                            AppDelegate.saveData()
                            
                            DispatchQueue.main.async {
                                self.manageCell.isUserInteractionEnabled = true
                                tableView.reloadData()
                            }
                        }
                    }
                    
                    alertController.addAction(createAction)
                    alertController.addAction(reloadAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            case 2:     // Account Settings
                // TODO: segue to account settings
                self.performSegue(withIdentifier: "settingsToAccount", sender: self)
            default: break
            }
        }
    }
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {
        
    }
    @IBAction func done(_ sender: UIBarButtonItem) {
        // release vc
        self.dismiss(animated: true, completion: nil)
    }
}
