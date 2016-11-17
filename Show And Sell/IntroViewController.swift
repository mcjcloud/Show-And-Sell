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
    @IBOutlet var messageLabel: UILabel!
    
    override func viewDidLoad() {
        if messageLabel == nil {
            messageLabel = UILabel()
        }
    }
    
}
