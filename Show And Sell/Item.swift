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
    
    init?(data itemJson: Data?) {
        if let data = itemJson {
            
            // get the json object
            var json: [String: Any]!
            do {
                json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            }
            catch {
                return nil
            }
            
            // parse the json
            if let itemId = json["ssItemId"] as? String,
                let groupId = json["groupId"] as? String,
                let ownerId = json["ownerId"] as? String,
                let name = json["name"] as? String,
                let price = json["price"] as? String,
                let condition = json["condition"] as? String,
                let itemDescription = json["description"] as? String,
                let thumbnail = json["thumbnail"] as? String,
                let approved = json["approved"]  as? Bool {
                
                // assign properties
                self.itemId = itemId
                self.groupId = groupId
                self.ownerId = ownerId
                self.name = name
                self.price = price
                self.condition = condition
                self.itemDescription = itemDescription
                self.thumbnail = thumbnail
                self.approved = approved
                
                // init object
                super.init()
            }
            else {
                return nil
            }
        }
        else {
            return nil
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
    
    // Get an Item array with Data
    static func itemArray(with itemsJson: Data?) -> [Item] {
        var result = [Item]()
        
        if let data = itemsJson {
            var json: [[String: Any]]!
            do {
                json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            }
            catch {
                return result
            }
            
            for item in json {
                if let itm = Item(data: try! JSONSerialization.data(withJSONObject: item)) {
                    result.append(itm)
                }
            }
        }
        
        // return result
        return result
    }
    
    static func approvedArray(with itemsJson: Data?) -> [Item] {
        var result = [Item]()
        
        if let data = itemsJson {
            var json: [[String: Any]]!
            do {
                json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            }
            catch {
                return result
            }
            
            for item in json {
                if let itm = Item(data: try! JSONSerialization.data(withJSONObject: item)) {
                    if itm.approved {
                        result.append(itm)
                    }
                }
            }
        }
        
        // return result
        return result
    }
}
