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
        static let emailKey = "emailKey"
        static let passwordKey = "passwordKey"
        //static let groupKey = "groupKey"
    }
    
    // user data
    var email: String?
    var password: String?
    //var groupId: String?
        
    // MARK: Coder
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.email, forKey: Keys.emailKey)
        aCoder.encode(self.password, forKey: Keys.passwordKey)    }
    
    init(email: String?, password: String?) {
        self.email = email
        self.password = password
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let email = aDecoder.decodeObject(forKey: Keys.emailKey) as? String
        let password = aDecoder.decodeObject(forKey: Keys.passwordKey) as? String
        
        // init the save data, user new array if no bookmarks.
        self.init(email: email, password: password)
    }
}
