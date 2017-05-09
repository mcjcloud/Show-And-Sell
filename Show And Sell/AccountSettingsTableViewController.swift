//
//  AccountSettingsTableViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 3/7/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import UIKit

class AccountSettingsTableViewController: UITableViewController {

    // MARK: UI Properties
    @IBOutlet var emailCell: UITableViewCell!
    @IBOutlet var emailField: UILabel!
    @IBOutlet var nameField: UILabel!
    @IBOutlet var passwordCell: UITableViewCell!
    @IBOutlet var passwordLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.title = "Account Settings"
        // update UI
        emailField.text = AppData.user?.email
        if let firstName = AppData.user?.firstName, let lastName = AppData.user?.lastName {
            nameField.text = "\(firstName) \(lastName)"
        }
        
        // check if password changing should be enabled
        if AppData.save.isGoogleSigned ?? false {
            
            // disable email
            emailCell.isUserInteractionEnabled = false
            emailField.textColor = UIColor.lightGray
            
            // disable password
            passwordCell.isUserInteractionEnabled = false
            passwordLabel.textColor = UIColor.lightGray
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        // update UI
        emailField.text = AppData.user?.email
        if let firstName = AppData.user?.firstName, let lastName = AppData.user?.lastName {
            nameField.text = "\(firstName) \(lastName)"
        }
        tableView.reloadData()
    }
    
    // MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // set the textField text for the destination
        if let dest = (segue.destination as? UINavigationController)?.childViewControllers[0] as? EditNameViewController {
            dest.firstName = AppData.user?.firstName ?? ""
            dest.lastName = AppData.user?.lastName ?? ""
        }
        else if let dest = (segue.destination as? UINavigationController)?.childViewControllers[0] as? EditEmailViewController {
            dest.email = AppData.user?.email ?? ""
        }
    }
    
    // MARK: TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch(indexPath.row) {
        case 0:
            self.performSegue(withIdentifier: "accountToName", sender: self)
        case 1:
            self.performSegue(withIdentifier: "accountToEmail", sender: self)
        case 2:
            self.performSegue(withIdentifier: "accountToPassword", sender: self)
        default: break
        }
    }
    
    // MARK: IBAction
    @IBAction func unwindToAccountSettings(_ segue: UIStoryboardSegue) {
        
    }

}
