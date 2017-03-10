//
//  IntroPageView.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/15/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import UIKit

class IntroViewController: UIViewController {

    // Properties to be accessed from other classes.
    
    override func viewDidLoad() {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let dest = segue.destination.childViewControllers[0] as? FindGroupTableViewController {
            dest.previousVC = self
        }
    }
    
}
