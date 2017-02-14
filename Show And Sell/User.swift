//
//  User.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/23/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import Foundation

class User: NSObject {
    
    // Properties
    var userId: String
    var email: String
    var password: String
    var firstName: String
    var lastName: String
    var groupId: String
    
    override var description: String {
        get {
            return "\(userId) \(password) \(firstName) \(lastName) \(email)"
        }
    }
    
    // init with data (may return nil)
    init?(data userJson: Data?) {
        
        if let data = userJson {
            //get the json in object
            var json: [String: Any]!
            do {
                json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
            }
            catch {
                return nil
            }
            
            if let id = json["ssUserId"] as? String,
                let pword = json["password"] as? String,
                let fName = json["firstName"] as? String,
                let lName = json["lastName"] as? String,
                let mail = json["email"] as? String {
                
                self.userId = id
                self.email = mail
                self.password = pword
                self.firstName = fName
                self.lastName = lName
                
                if let group = json["groupId"] as? String {
                    self.groupId = group
                }
                else {
                    self.groupId = ""
                }
                
                super.init()
            }
            else {
                print()
                print("RETURNING NIL DUE TO INVALID VALUE IN DICTIONARY")
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    // Manual init
    init(userId: String, email: String, groupId: String, password: String, firstName: String, lastName: String) {
        self.userId = userId
        self.email = email
        self.groupId = groupId
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
    }
    
    // manual init without userId or groupId
    init(email: String, password: String, firstName: String, lastName: String) {
        self.email = email
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        
        self.userId = ""
        self.groupId = ""
    }
}
