//
//  User.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/23/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//

import Foundation

class User: NSObject {
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
    init?(userJson: Data) {
        
        //get the json in object
        var json: [String: Any]!
        
        do {
            print("user data: \(String(data: userJson, encoding: .utf8))")
            
            json = try JSONSerialization.jsonObject(with: userJson) as! [String: Any]
            if let id = json["ssUserId"] as? String,
                let uname = json["username"] as? String,
                let pword = json["password"] as? String,
                let fName = json["firstName"] as? String,
                let lName = json["lastName"] as? String,
                let mail = json["email"] as? String {
                
                userId = id
                username = uname
                password = pword
                firstName = fName
                lastName = lName
                email = mail
                
                if let group = json["groupId"] as? String {
                    groupId = group
                }
                else {
                    groupId = ""
                }
                
                super.init()
            }
            else {
                print()
                print("RETURNING NIL DUE TO INVALID VALUE IN DICTIONARY")
                return nil
            }
            
        }
        catch {
            print("ERROR IN ARRAY JSON")
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
