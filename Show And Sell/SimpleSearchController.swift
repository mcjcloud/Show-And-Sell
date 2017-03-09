//
//  SimpleSearchController.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 2/16/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//
//  Custom implementation of SearchController to use custom SearchBar (which has no cancel button)
//

import UIKit

class SimpleSearchController: UISearchController, UISearchBarDelegate {

    // search bar returning
    var _searchBar: UISearchBar!
    override var searchBar: UISearchBar {
        if _searchBar == nil {
            _searchBar = SimpleSearchBar()
            _searchBar.delegate = self
        }
        return _searchBar
    }

}
