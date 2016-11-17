//
//  SettingsViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 10/11/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
            destination.previousViewController = self
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "settingsToFinder", sender: self)
            }
        }
    }
    
    @IBAction func unwindToSettings(segue: UIStoryboardSegue) {
        
    }
}
