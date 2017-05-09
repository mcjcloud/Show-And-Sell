//
//  SettingsViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 10/11/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController, UIPopoverPresentationControllerDelegate, MFMailComposeViewControllerDelegate {
    @IBOutlet var manageCell: UITableViewCell!
    @IBOutlet var reportBugCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
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
            case 0:     // Manage Group
                if let _ = AppData.myGroup {
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
                        HttpRequestManager.group(withAdminId: AppData.user!.userId) { group, response, error in
                            print("got myGroup")
                            AppData.myGroup = group
                            AppData.saveData()
                            
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
            case 1:     // Account Settings
                // TODO: segue to account settings
                self.performSegue(withIdentifier: "settingsToAccount", sender: self)
            default: break
            }
        }
        else {
            if indexPath.row == 0 {
                self.tableView.reloadData()
                // compose email
                let mailComposerVC = MFMailComposeViewController()
                mailComposerVC.mailComposeDelegate = self
                
                mailComposerVC.setToRecipients(["showandsellmail@gmail.com"])
                mailComposerVC.setSubject("Bug Report")
                mailComposerVC.setMessageBody("I found a bug!", isHTML: false)
                if MFMailComposeViewController.canSendMail() {
                    self.present(mailComposerVC, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: MFMailViewController delegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {
        // do nothing
    }
    @IBAction func done(_ sender: UIBarButtonItem) {
        // release vc
        self.dismiss(animated: true, completion: nil)
    }
}
