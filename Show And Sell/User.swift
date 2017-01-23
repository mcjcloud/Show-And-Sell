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
    var username: String
    var password: String
    var firstName: String
    var lastName: String
    var email: String
    
    var groupId: String {
        didSet {
            // Make PUT request for user
            HttpRequestManager.updateUser(id: userId, newUsername: username, oldPassword: password, newPassword: password, newFirstName: firstName, newLastName: lastName, newEmail: email, newGroupId: groupId) { user, response, error in
                print("Update user returned")
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    if statusCode != 200 {
                        print("ERROR UPDATING USER")
                    }
                }
            }
        }
    }
    
    override var description: String {
        get {
            return "\(userId) \(username) \(password) \(firstName) \(lastName) \(email)"
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
                let uname = json["username"] as? String,
                let pword = json["password"] as? String,
                let fName = json["firstName"] as? String,
                let lName = json["lastName"] as? String,
                let mail = json["email"] as? String {
                
                self.userId = id
                self.username = uname
                self.password = pword
                self.firstName = fName
                self.lastName = lName
                self.email = mail
                
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
    init(userId: String, groupId: String, username: String, password: String, firstName: String, lastName: String, email: String) {
        self.userId = userId
        self.groupId = groupId
        self.username = username
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}
