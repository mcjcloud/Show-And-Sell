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
    var latitude: Double
    var longitude: Double
    var locationDetail: String
    //var itemsSold: Int         // TODO: include this is needed
 
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
                let latitude = json["latitude"] as? Double,
                let longitude = json["longitude"] as? Double,
                let locationDetail = json["locationDetail"] as? String {
                
                self.groupId = groupId
                self.name = name
                self.adminId = adminId
                self.dateCreated = dateCreated
                self.latitude = latitude
                self.longitude = longitude
                self.locationDetail = locationDetail
                
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
    
    init(groupId: String, name: String, adminId: String, dateCreated: String, latitude: Double, longitude: Double, locationDetail: String) {
        self.groupId = groupId
        self.name = name
        self.adminId = adminId
        self.dateCreated = dateCreated
        self.latitude = latitude
        self.longitude = longitude
        self.locationDetail = locationDetail
    }
    // group without groupId or date
    init(name: String, adminId: String, latitude: Double, longitude: Double, locationDetail: String) {
        self.name = name
        self.adminId = adminId
        self.latitude = latitude
        self.longitude = longitude
        self.locationDetail = locationDetail
        
        self.groupId = ""
        self.dateCreated = ""
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
