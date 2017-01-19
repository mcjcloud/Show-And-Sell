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
            print("setting prev VC")
            destination.previousViewController = self
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch(indexPath.row) {
            case 0:
                self.performSegue(withIdentifier: "settingsToFinder", sender: self)
            case 1:
                if let _ = AppDelegate.myGroup {
                    self.performSegue(withIdentifier: "settingsToManage", sender: self)
                }
                else {
                    let alertController = UIAlertController(title: "Group not found", message: "A group with your user was not found.", preferredStyle: .alert)
                    
                    let createAction = UIAlertAction(title: "Create", style: .default) { action in
                        // TODO: Create group.
                        /*
                        let viewController: UIViewController! = self.storyboard?.instantiateViewController(withIdentifier: "createGroup")
                        let nav = UINavigationController(rootViewController: viewController)
                        nav.modalPresentationStyle = .popover
                        let popover = nav.popoverPresentationController
                        
                        // size the popover.
                        viewController.preferredContentSize = CGSize(width: UIScreen.main.bounds.width - 10, height: UIScreen.main.bounds.height * 0.5)
                        popover?.delegate = self
                        popover?.sourceView = self.view
                        popover?.sourceRect = CGRect(x: 100, y: 100, width: 0, height: 0)
                        
                        self.present(nav, animated: true, completion: nil)
                        */
                        let inputController = UIAlertController(title: "Create Group", message: "Enter the name for the group", preferredStyle: .alert)
                        let doneAction = UIAlertAction(title: "Create", style: .default) { inputAction in
                            // TODO: create the group with the specified name.
                            if let name = inputController.textFields?[0].text, name.characters.count > 0 {
                                HttpRequestManager.postGroup(name: name, adminId: AppDelegate.user!.userId, password: AppDelegate.user!.password, location: "remove this", locationDetail: "remove this") { group, response, error in
                                    
                                }
                            }
                            else {
                                inputController.title = "Name cannot be empty"
                                self.present(inputController, animated: true, completion: nil)
                            }
                        }
                        
                        inputController.addTextField(configurationHandler: nil)
                        inputController.addAction(doneAction)
                        
                        self.present(inputController, animated: true, completion: nil)
                    }
                    let reloadAction = UIAlertAction(title: "Reload", style: .default) { action in
                        print("reloading myGroup")
                        // start animation
                        let refresher = UIRefreshControl(frame: self.arrowView.frame)
                        DispatchQueue.main.async {
                            self.arrowImage.removeFromSuperview()
                            self.arrowView.addSubview(refresher)
                            
                            refresher.beginRefreshing()
                            self.manageCell.isUserInteractionEnabled = false
                        }
                        // get myGroup
                        HttpRequestManager.getGroup(with: AppDelegate.user!.userId) { group, response, error in
                            print("got myGroup")
                            AppDelegate.myGroup = group
                            AppDelegate.saveData()
                            
                            DispatchQueue.main.async {
                                refresher.endRefreshing()
                                self.manageCell.isUserInteractionEnabled = true
                                refresher.removeFromSuperview()
                                self.arrowView.addSubview(self.arrowImage)
                                tableView.reloadData()
                            }
                        }
                    }
                    
                    alertController.addAction(createAction)
                    alertController.addAction(reloadAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            default: break
            }
        }
    }
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {
        
    }
}