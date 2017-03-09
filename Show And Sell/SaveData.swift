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
        static let isGoogleSignedKey = "googleSignedKey"
    }
    
    // user data
    var email: String?
    var password: String?
    var isGoogleSigned: Bool?
    //var groupId: String?
        
    // MARK: Coder
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.email, forKey: Keys.emailKey)
        aCoder.encode(self.password, forKey: Keys.passwordKey)
        aCoder.encode(self.isGoogleSigned, forKey: Keys.isGoogleSignedKey)
    }
    
    init(email: String?, password: String?, isGoogleSigned: Bool?) {
        self.email = email
        self.password = password
        self.isGoogleSigned = isGoogleSigned ?? false
    }
    required convenience init?(coder aDecoder: NSCoder) {
        let email = aDecoder.decodeObject(forKey: Keys.emailKey) as? String
        let password = aDecoder.decodeObject(forKey: Keys.passwordKey) as? String
        let isGoogleSigned = aDecoder.decodeObject(forKey: Keys.isGoogleSignedKey) as? Bool
        
        // init the save data, user new array if no bookmarks.
        self.init(email: email, password: password, isGoogleSigned: isGoogleSigned)
    }
}
