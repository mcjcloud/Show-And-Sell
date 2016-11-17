//
//  HttpRequestManager.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/23/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//
/*
    Defines a set of functions to be be used to make URL requests and manage user, group and item models from the database
 */

import Foundation

class HttpRequestManager {
    public static let SERVER_URL = "http://192.168.1.107:8080/showandsell"
    
    /*
     *      USER METHODS
     */
    static func getUser(withGuid id: String, andPassword password: String, completion: @escaping (User?, URLResponse?) -> Void) {
        
        // the url to make the URLRequest ot
        let requestURL = URL(string: "\(SERVER_URL)/api/users/\(id)?password=\(password)")
        
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        
        // make the request and call the completion method with the new user
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            completion(User(userJson: data!, withIndexInArray: 0), response)
        }
        task.resume()
    }
    static func getUser(withUsername username: String, andPassword password: String, completion: @escaping (User?, URLResponse?, Error?) -> Void) {
        
        // the request URL
        let requestURL = URL(string: "\(SERVER_URL)/api/users?username=\(username)&password=\(password)")
        
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        
        // make the request for the user, and return it in the completion method
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let d = data {
                completion(User(userJson: d, withIndexInArray: 0), response, error)
            }
            else {
                completion(nil, response, error)
            }
        }
        task.resume()
    }
    
    // create user request
    static func createUser(username: String, password: String, firstName: String, lastName: String, email: String, completion: @escaping (User?, URLResponse?) -> Void) {
        
        // check validity of data
        let pattern = "[a-zA-Z0-9]"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        if !(numberOfMatches(withRegex: regex, andStrings: username, password, firstName, lastName, email) > 0) {
            // call completion, invalid input
            completion(nil, nil)
        }
        
        // create json of user data in dictionary
        let json = ["username":"\(username)", "password":"\(password)", "firstName":"\(firstName)", "lastName":"\(lastName)", "email":"\(email)"]
        let body = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create request
        let requestURL = URL(string: "\(SERVER_URL)/api/users/")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // a JSON of the user to be created.
        print()
        print("body: \(body)")
        request.httpBody = body
        request.timeoutInterval = 10        // seconds
        
        // make the request, call the completion method
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            print()
            print("response: \((response as? HTTPURLResponse)?.statusCode)")
            if let _ = error {
                print()
                print("CREATE FAILED")
                print()
            }
            // if no error
            else {
                // call the completion, creating a new user object for the user that was just created.
                completion(User(userJson: data!, withIndexInArray: nil), response)
            }
        }
        task.resume()
    }
    
    /*
     *      GET GROUP METHODS
     */
    // get a group by its group id.
    static func getGroup(withId id: String, completion: @escaping (Group?, URLResponse?, Error?) -> Void) {
        
        // build request
        let requestURL = URL(string: "\(SERVER_URL)/api/groups/\(id)")
        
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            print("Group data: \(String(data: data!, encoding: .utf8))")
            
            var group: Group?
            
            // json dictionary
            var json: [String: Any]!
            do {
                if let d = data {
                    json = try JSONSerialization.jsonObject(with: d) as? [String: Any]
                }
                else {
                    // return the nil group.
                    completion(group, response, error)
                }
            }
            catch {
                print("ERROR GETTING GROUP")
            }
            
            // convert into group object.
            if let jsonObj = json {
                if let groupId = jsonObj["ssGroupId"], let name = jsonObj["name"], let adminId = jsonObj["admin"], let dateCreated = jsonObj["dateCreated"] {
                    group = Group(groupId: groupId as! String, name: name as! String, adminId: adminId as! String, dateCreated: dateCreated as! String)
                }
                else {
                    group = nil
                }
            }
            
            // complete the task
            completion(group, response, error)
        }
        task.resume()
    }
    
    static func getGroups(completion: @escaping ([Group]?, URLResponse?, Error?) -> Void) {
        
        // setup request
        let requestURL = URL(string: "\(SERVER_URL)/api/groups/")
        
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var groups: [Group]?
            
            // get json
            var json: [[String: Any]]?
            do {
                if let d = data {
                    json = try JSONSerialization.jsonObject(with: d) as? [[String: Any]]
                }
                else {
                    // return the empty array.
                    completion(groups, response, error)
                }
            }
            catch {
                print("ERROR GETTING GROUPS")
            }
            
            // parse json into group array
            if let array = json {
                groups = [Group]()
                
                for item in array {
                    if let groupId = item["ssGroupId"], let name = item["name"], let adminId = item["admin"], let dateCreated = item["dateCreated"] {
                        groups!.append(Group(groupId: groupId as! String, name: name as! String, adminId: adminId as! String, dateCreated: dateCreated as! String))
                    }
                }
            }
            
            // complete the task
            completion(groups, response, error)
            
        }
        task.resume()
    }
    
    /*
     *      ITEM METHODS
     */
    // Get all items in the database.
    static func getAllItems(completion: @escaping ([Item], URLResponse?, Error?) -> Void) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/items/")
        
        // url request
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10    // seconds
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var items: [Item] = [Item]()
            
            var json: [[String: String]]?
            do {
                if let d = data {
                    json = try JSONSerialization.jsonObject(with: d) as? [[String: String]]
                }
                else {
                    // return the empty array.
                    completion(items, response, error)
                }
            }
            catch {
                print("GET ITEM ERROR")
            }
            
            // Convert the recieved json into an array of items.
            if let jsonObj = json {
                for i in 0..<jsonObj.count {
                    print()
                    print("i: \(i)")
                    let item = jsonObj[i]
                    // check the value of all the json data and add a new
                    if let itemId = item["ssItemId"],
                        let groupId = item["groupId"],
                        let ownerId = item["ownerId"],
                        let name = item["name"],
                        let price = item["price"],
                        let condition = item["condition"],
                        let description = item["description"],
                        let thumbnail = item["thumbnail"] {
                        print("ADDED ITEM TO ARRAY")
                        
                        // check if item is already in bookmarked array. If so, put that item in place of the one retrieved to perserve the isBookmarked.
                        let item: Item!
                        if let bmarkedItem = AppDelegate.bookmarks?.first(where: { e in e.itemId == itemId }) {
                            item = bmarkedItem
                        }
                        else {
                            item = Item(itemId: itemId, groupId: groupId, ownerId: ownerId, name: name, price: price, condition: condition, itemDescription: description, thumbnail: thumbnail, isBookmarked: false)
                        }
                        
                        items.append(item)
                    }
                    else {
                        print("ERROR GETTING A PARTICULAR ITEM")
                    }
                }
            }
            else {
                print()
                print("ERROR WITH ITEM ARRAY JSON")
            }
            
            // call the completion method, giving back the items and teh response
            completion(items, response, error)
            
        }
        task.resume()
    }
    
    // get items from a particular group
    static func getItems(with groupId: String, completion: @escaping ([Item], URLResponse?, Error?) -> Void) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/items?groupId=\(groupId)")
        
        print()
        print("URL: \(requestURL?.absoluteString)")
        
        // url request
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10    // seconds
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var items: [Item] = [Item]()
            
            var json: [[String: String]]?
            do {
                if let d = data {
                    json = try JSONSerialization.jsonObject(with: d) as? [[String: String]]
                }
                else {
                    // return the empty array.
                    completion(items, response, error)
                }
            }
            catch {
                print("GET ITEM ERROR")
            }
            
            // Convert the recieved json into an array of items.
            if let jsonObj = json {
                for i in 0..<jsonObj.count {
                    print()
                    print("i: \(i)")
                    let item = jsonObj[i]
                    // check the value of all the json data and add a new
                    if let itemId = item["ssItemId"],
                        let groupId = item["groupId"],
                        let ownerId = item["ownerId"],
                        let name = item["name"],
                        let price = item["price"],
                        let condition = item["condition"],
                        let description = item["description"],
                        let thumbnail = item["thumbnail"] {
                        print("ADDED ITEM TO ARRAY")
                        
                        // check if item is already in bookmarked array. If so, put that item in place of the one retrieved to perserve the isBookmarked.
                        let item: Item!
                        if let bmarkedItem = AppDelegate.bookmarks?.first(where: { e in e.itemId == itemId }) {
                            item = bmarkedItem
                        }
                        else {
                            item = Item(itemId: itemId, groupId: groupId, ownerId: ownerId, name: name, price: price, condition: condition, itemDescription: description, thumbnail: thumbnail, isBookmarked: false)
                        }
                        
                        items.append(item)
                    }
                    else {
                        print("ERROR GETTING A PARTICULAR ITEM")
                    }
                }
            }
            else {
                print()
                print("ERROR WITH ITEM ARRAY JSON")
            }
            
            // call the completion method, giving back the items and teh response
            completion(items, response, error)
            
        }
        task.resume()
    }
    
    // post an item to a group
    static func postItem(with item: Item, completion: @escaping (Item?, URLResponse?, Error?) -> Void) {
        
        // create the request
        let requestURL = URL(string: "\(SERVER_URL)/api/items/")
        var request = URLRequest(url: requestURL!)
        
        // request properties
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // build body
        let bodyJson: [String: String] = ["groupId":"\(item.groupId)", "ownerId":"\(item.ownerId)", "name":"\(item.name)", "price":"\(item.price)", "condition":"\(item.condition)", "description":"\(item.itemDescription)", "thumbnail":"\(item.thumbnail)"]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyJson, options: .prettyPrinted)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var json: [String: String]!
            do {
                json = try JSONSerialization.jsonObject(with: data!) as? [String: String]
            }
            catch {
                print("error creating item")
            }
            
            var item: Item?
            if let itemId = json["ssItemId"], let groupId = json["groupId"], let ownerId = json["ownerId"], let name = json["name"], let price = json["price"], let description = json["description"], let condition = json["condition"], let thumbnail = json["thumbnail"] {
                item = Item(itemId: itemId, groupId: groupId, ownerId: ownerId, name: name, price: price, condition: condition, itemDescription: description, thumbnail: thumbnail, isBookmarked: false)
            }
            
            // complete the request
            completion(item, response, error)
        }
        task.resume()
    }
    
    /*
     *  Bookmark methods
     */
    static func getBookmarks(with userId: String, password: String, completion: @escaping ([Item]?, URLResponse?, Error?) -> Void) {
        let requestURL = URL(string: "\(SERVER_URL)/api/bookmarks?userId=\(userId)&password=\(password)")
        var request = URLRequest(url: requestURL!)
        
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var items: [Item] = [Item]()
            
            var json: [[String: String]]?
            do {
                if let d = data {
                    json = try JSONSerialization.jsonObject(with: d) as? [[String: String]]
                }
                else {
                    // return the empty array.
                    completion(items, response, error)
                }
            }
            catch {
                print("GET Bookmarks ERROR")
            }
            
            // Convert the recieved json into an array of items.
            if let jsonObj = json {
                for i in 0..<jsonObj.count {
                    print()
                    print("i: \(i)")
                    let item = jsonObj[i]
                    // check the value of all the json data and add a new
                    if let itemId = item["ssItemId"],
                        let groupId = item["groupId"],
                        let ownerId = item["ownerId"],
                        let name = item["name"],
                        let price = item["price"],
                        let condition = item["condition"],
                        let description = item["description"],
                        let thumbnail = item["thumbnail"] {
                        print("ADDED ITEM TO ARRAY")
                        let item = Item(itemId: itemId, groupId: groupId, ownerId: ownerId, name: name, price: price, condition: condition, itemDescription: description, thumbnail: thumbnail, isBookmarked: true)
                        items.append(item)
                    }
                    else {
                        print("ERROR GETTING A PARTICULAR ITEM")
                    }
                }
            }
            else {
                print()
                print("ERROR WITH ITEM ARRAY JSON")
            }
            
            // call the completion method, giving back the items and teh response
            completion(items, response, error)
        }
        task.resume()
    }
    
    /*
     * Helper methods
     */
    static func numberOfMatches(withRegex regex: NSRegularExpression, andStrings strings: String...) -> Int {
        var matchCount = 0
        for string in strings {
            if regex.numberOfMatches(in: string, options: [], range: NSRange(location: 0, length: string.characters.count)) > 0 {
                matchCount += 1
            }
        }
        
        return matchCount
    }
}


