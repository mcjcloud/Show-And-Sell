//
//  AppData.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 4/28/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import Foundation

struct AppData {
    // reference to the written data
    static var save: SaveData!
    
    // bookmarks and items reference across app
    static var bookmarks: [Item: String]?
    static var items: [Item]?
    
    static var user: User? {
        didSet {
            save.email = user?.email
            save.password = user?.password ?? ""
            self.saveData()
        }
    }
    static var group: Group? {
        didSet {
            user?.groupId = group?.groupId ?? ""
            //self.saveData()
            
            if let u = self.user {
                // Make PUT request for user
                HttpRequestManager.put(user: u, currentPassword: user?.password ?? "") { user, response, error in
                    self.user = user
                }
            }
        }
    }
    static var myGroup: Group?
    static var displayItem: Item?
    
    // MARK: NSCoding
    static func saveData() {
        
        let success = NSKeyedArchiver.archiveRootObject(self.save, toFile: SaveData.archiveURL.path)
        if success {
            print("Saved successfully")
        }
        else {
            print("Save Failed")
        }
    }
    static func loadData() -> SaveData? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: SaveData.archiveURL.path) as! SaveData?
    }
}
