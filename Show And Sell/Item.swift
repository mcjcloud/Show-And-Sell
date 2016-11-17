//
//  Item.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 10/6/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//
//  Contains data relating to an Item that can be stored on the server. implements NSCoding so it can persist accross sessions.

import Foundation

/*
// extend bool to add int converter
extension Bool {
    init(_ int: Int) {
        if int != 0 {
            self.init(true)
        }
        else {
            self.init(false)
        }
    }
    var int: Int {
        get {
            return self ? 1 : 0
        }
        set {
            self = newValue != 0 ? true : false
        }
    }
}
*/

class Item: NSObject {
    
    // MARK: Archive paths
    //static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    //static let archiveURL = documentsDirectory.appendingPathComponent("items")
    
    /* MARK: Probably don't need this if bookmarks are handled by the server.
    // Keys for item data
    struct Keys {
        static let itemIdKey = "itemIdKey"
        static let groupIdKey = "groupIdKey"
        static let ownerIdKey = "ownerIdKey"
        static let nameKey = "nameKey"
        static let priceKey = "priceKey"
        static let conditionKey = "conditionKey"
        static let descriptionKey = "descKey"
        static let thumbnailKey = "thumbnailKey"
        static let isBookmarkedKey = "isBookmarkedKey"
    }
    */
    
    // Properties
    var itemId: String
    var groupId: String
    var ownerId: String
    var name: String
    var price: String
    var condition: String
    var itemDescription: String
    var thumbnail: String
    
    var isBookmarked: Bool {
        didSet {
            // add/remove bookmark on server.
            if isBookmarked {
                // TODO: add a bookmark.
            }
            else {
                // TODO: remove the bookmark.
            }
        }
    }
    
    init(itemId: String, groupId: String, ownerId: String, name: String, price: String, condition: String, itemDescription: String, thumbnail: String, isBookmarked: Bool) {
        self.itemId = itemId
        self.groupId = groupId
        self.ownerId = ownerId
        self.name = name
        self.price = price
        self.condition = condition
        self.itemDescription = itemDescription
        self.thumbnail = thumbnail
        self.isBookmarked = isBookmarked
    }
    
    /* MARK: No need for NSCoding if bookmarks are handled by the server
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        // encode the item data
        aCoder.encode(self.itemId, forKey: Keys.itemIdKey)
        aCoder.encode(self.groupId, forKey: Keys.groupIdKey)
        aCoder.encode(self.ownerId, forKey: Keys.ownerIdKey)
        aCoder.encode(self.name, forKey: Keys.nameKey)
        aCoder.encode(self.price, forKey: Keys.priceKey)
        aCoder.encode(self.condition, forKey: Keys.conditionKey)
        aCoder.encode(self.itemDescription, forKey: Keys.descriptionKey)
        aCoder.encode(self.thumbnail, forKey: Keys.thumbnailKey)
    }
    // init implemented from NSCoding, decode all the stored data.
    required convenience init?(coder aDecoder: NSCoder) {
        let itemId = aDecoder.decodeObject(forKey: Keys.itemIdKey) as! String
        let groupId = aDecoder.decodeObject(forKey: Keys.groupIdKey) as! String
        let ownerId = aDecoder.decodeObject(forKey: Keys.ownerIdKey) as! String
        let name = aDecoder.decodeObject(forKey: Keys.nameKey) as! String
        let price = aDecoder.decodeObject(forKey: Keys.priceKey) as! String
        let condition = aDecoder.decodeObject(forKey: Keys.conditionKey) as! String
        let itemDescription = aDecoder.decodeObject(forKey: Keys.descriptionKey) as! String
        let thumbnail = aDecoder.decodeObject(forKey: Keys.thumbnailKey) as! String
        
        self.init(itemId: itemId, groupId: groupId, ownerId: ownerId, name: name, price: price, condition: condition, itemDescription: itemDescription, thumbnail: thumbnail, isBookmarked)
    }
     */
}
