//
//  Group.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 10/25/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import Foundation

class Group: NSObject {
    
    // properties
    var groupId: String
    var name: String
    var adminId: String
    var dateCreated: String
    var address: String
    var routing: String
    var latitude: Double
    var longitude: Double
    var locationDetail: String
    var itemsSold: Int         // TODO: include this if needed
    var rating: Float
 
    init?(data groupJson: Data?) {
        if let data = groupJson {
            
            // get the json object
            var json: [String: Any]!
            do {
                json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            }
            catch {
                return nil
            }
            
            // parse the json
            if let groupId = json["ssGroupId"] as? String,
                let name = json["name"] as? String,
                let adminId = json["adminId"] as? String,
                let dateCreated = json["dateCreated"] as? String,
                let address = json["address"] as? String,
                let routing = json["routing"] as? String,
                let latitude = json["latitude"] as? Double,
                let longitude = json["longitude"] as? Double,
                let locationDetail = json["locationDetail"] as? String,
                let itemsSold = json["itemsSold"] as? Int,
                let rating = json["rating"] as? Float {
                
                self.groupId = groupId
                self.name = name
                self.adminId = adminId
                self.dateCreated = dateCreated
                self.address = address
                self.routing = routing
                self.latitude = latitude
                self.longitude = longitude
                self.locationDetail = locationDetail
                self.itemsSold = itemsSold
                self.rating = rating
                
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
    
    init(groupId: String, name: String, adminId: String, dateCreated: String, address: String, routing: String, latitude: Double, longitude: Double, locationDetail: String, itemsSold: Int, rating: Float) {
        self.groupId = groupId
        self.name = name
        self.adminId = adminId
        self.dateCreated = dateCreated
        self.address = address
        self.routing = routing
        self.latitude = latitude
        self.longitude = longitude
        self.locationDetail = locationDetail
        self.itemsSold = itemsSold
        self.rating = rating
    }
    // group without groupId or date
    init(name: String, adminId: String, address: String, routing: String, latitude: Double, longitude: Double, locationDetail: String) {
        self.name = name
        self.adminId = adminId
        self.address = address
        self.routing = routing
        self.latitude = latitude
        self.longitude = longitude
        self.locationDetail = locationDetail
        
        self.groupId = ""
        self.dateCreated = ""
        self.rating = 0.0
        self.itemsSold = 0
    }
    
    // get Group array from json
    static func groupArray(with groupsJson: Data?) -> [Group] {
        var result = [Group]()
        
        if let data = groupsJson {
            var json: [[String: Any]]!
            do {
                json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            }
            catch {
                return result
            }
            
            for group in json {
                if let grp = Group(data: try! JSONSerialization.data(withJSONObject: group)) {
                    result.append(grp)
                }
            }
        }
        
        // return result
        return result
    }
}
