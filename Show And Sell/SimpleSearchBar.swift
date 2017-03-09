//
//  SimpleSearchBar.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 2/16/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//
//  Custom SearchBar implementation to show a search bar with no cancel button
//

import UIKit

class SimpleSearchBar: UISearchBar {

    // cancel button override
    override func setShowsCancelButton(_ showsCancelButton: Bool, animated: Bool) {
        // do nothing
    }

}
