//
//  Group.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 10/25/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import Foundation

class Group: NSObject{
    
    // properties
    var groupId: String
    var name: String
    var adminId: String
    var dateCreated: String
    //var itemsSold: Int         // TODO: include this is needed
 
    init(groupId: String, name: String, adminId: String, dateCreated: String) {
        self.groupId = groupId
        self.name = name
        self.adminId = adminId
        self.dateCreated = dateCreated
    }
}
