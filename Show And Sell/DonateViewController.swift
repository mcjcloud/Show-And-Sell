//
//  DonateViewController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/5/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

class DonateViewController: UIViewController {
    @IBOutlet var donateButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        // set button titles for states
        // using viewWillAppear because it will be called each time the view comes on the screen.
        donateButton.setTitle("Please choose a group in settings", for: .disabled)
        donateButton.setTitle("Donate Item", for: .normal)
        
        // if there is no group set, false, else true
        donateButton.isEnabled = AppDelegate.group?.groupId != "" && AppDelegate.group?.groupId != nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Navigation
    @IBAction func cancelDonate(segue: UIStoryboardSegue) {
        // cancelled the donate action
        
    }
}
