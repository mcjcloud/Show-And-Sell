//
//  SaveData.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 10/18/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import Foundation
import UIKit

class SaveData: NSObject, NSCoding {
    
    // MARK: Archive paths
    static let documentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let archiveURL = documentsDirectory.appendingPathComponent("data")
    
    // a series of properties for the data to be saved.
    struct Keys {
        static let usernameKey = "usernameKey"
        static let passwordKey = "passwordKey"
        static let groupKey = "groupKey"
    }
    
    // user data
    var username: String?
    var password: String?
    var group: String?
        
    // MARK: Coder
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.username, forKey: Keys.usernameKey)
        aCoder.encode(self.password, forKey: Keys.passwordKey)
        aCoder.encode(self.group, forKey: Keys.groupKey)
    }
    
    init(username: String?, password: String?, group: String?) {
        self.username = username
        self.password = password
        self.group = group
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let username = aDecoder.decodeObject(forKey: Keys.usernameKey) as? String
        let password = aDecoder.decodeObject(forKey: Keys.passwordKey) as? String
        let group = aDecoder.decodeObject(forKey: Keys.groupKey) as? String
        
        // init the save data, user new array if no bookmarks.
        self.init(username: username, password: password, group: group)
    }
}
