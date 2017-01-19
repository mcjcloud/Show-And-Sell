//
//  Item.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 10/6/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//
//  Contains data relating to an Item that can be stored on the server. implements NSCoding so it can persist accross sessions.

import Foundation

class Item: NSObject {
    
    // Properties
    var itemId: String
    var groupId: String
    var ownerId: String
    var name: String
    var price: String
    var condition: String
    var itemDescription: String
    var thumbnail: String
    var approved: Bool
    
    var isBookmarked: Bool? {
        get {
            return AppDelegate.bookmarks?.contains(where: { (k, v) in k.itemId == self.itemId }) ?? false
        }
    }
    
    init(itemId: String, groupId: String, ownerId: String, name: String, price: String, condition: String, itemDescription: String, thumbnail: String, approved: Bool) {
        self.itemId = itemId
        self.groupId = groupId
        self.ownerId = ownerId
        self.name = name
        self.price = price
        self.condition = condition
        self.itemDescription = itemDescription
        self.thumbnail = thumbnail
        self.approved = approved
    }
}
