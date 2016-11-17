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
    
    override var description: String {
        get {
            return "\(userId) \(username) \(password) \(firstName) \(lastName) \(email)"
        }
    }
    
    // keys for data
    /*
    struct Keys {
        static let userIdKey = "userIdKey"
        static let usernameKey = "usernameKey"
        static let passwordKey = "passwordKey"
        static let firstNameKey = "firstNameKey"
        static let lastNameKey = "lastNameKey"
        static let emailKey = "emailKey"
    }
    */
    
    // init with data (may return nil)
    init?(userJson: Data, withIndexInArray index: Int?) {
        
        //get the json in object
        var json: [[String: String]]!
        var altJson: [String: String]!
        
        // if its in an array
        if let i = index {
            do {
                json = try JSONSerialization.jsonObject(with: userJson) as! [[String: String]]
                if let id = json[i]["ssUserId"],
                    let uname = json[i]["username"],
                    let pword = json[i]["password"],
                    let fName = json[i]["firstName"],
                    let lName = json[i]["lastName"],
                    let mail = json[i]["email"] {
                    
                    userId = id
                    username = uname
                    password = pword
                    firstName = fName
                    lastName = lName
                    email = mail
                    
                    super.init()
                }
                else {
                    print()
                    print("RETURNING NIL DUE TO INVALID VALUE IN DICTIONARY")
                    return nil
                }
                
            } catch {
                print("ERROR IN ARRAY JSON")
                return nil
            }
        }
        // if its just the user,not in an array
        else {
            do {
                print()
                print("trying to do [String: String]")
                altJson = try JSONSerialization.jsonObject(with: userJson) as! [String: String]
                
                if let id = altJson["ssUserId"],
                    let uname = altJson["username"],
                    let pword = altJson["password"],
                    let fName = altJson["firstName"],
                    let lName = altJson["lastName"],
                    let mail = altJson["email"] {
                    
                    userId = id
                    username = uname
                    password = pword
                    firstName = fName
                    lastName = lName
                    email = mail
                    
                    super.init()
                }
                else {
                    print()
                    print("RETURNING NIL DUE TO INVALID ALTJSON")
                    return nil
                }
            } catch {
                print("ERROR IN NON-ARRAY JSON")
                return nil
            }
        }
    }
    
    // Manual init
    init(userId: String, username: String, password: String, firstName: String, lastName: String, email: String) {
        self.userId = userId
        self.username = username
        self.password = password
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
    }
}
