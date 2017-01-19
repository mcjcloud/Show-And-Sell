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
    public static let SERVER_URL = "http://68.248.214.70:8080/showandsell"
    //public static let SERVER_URL = "http://192.168.1.107:8080/showandsell"
    
    /*
     *      USER METHODS
     */
    static func getUser(withGuid id: String, andPassword password: String, completion: @escaping (User?, URLResponse?) -> Void) {
        
        // the url to make the URLRequest to
        let requestURL = URL(string: "\(SERVER_URL)/api/users/userbyuserid?id=\(id)&password=\(password)")
        
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        
        // make the request and call the completion method with the new user
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            completion(User(userJson: data!), response)
        }
        task.resume()
    }
    static func getUser(withUsername username: String, andPassword password: String, completion: @escaping (User?, URLResponse?, Error?) -> Void) {
        
        // the request URL
        let requestURL = URL(string: "\(SERVER_URL)/api/users/userbyusername?username=\(username)&password=\(password)")
        
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        
        // make the request for the user, and return it in the completion method
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data: Data?, response: URLResponse?, error: Error?) -> Void in
            if let d = data {
                completion(User(userJson: d), response, error)
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
        let requestURL = URL(string: "\(SERVER_URL)/api/users/create")
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
                completion(User(userJson: data!), response)
            }
        }
        task.resume()
    }
    
    // update user
    static func updateUser(id: String, newUsername: String, oldPassword: String, newPassword: String, newFirstName: String, newLastName: String, newEmail: String, newGroupId: String, completion: @escaping (User?, URLResponse?, Error?) -> Void) {
        
        // check validity of data
        let pattern = "[a-zA-Z0-9]"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        if !(numberOfMatches(withRegex: regex, andStrings: newUsername, newPassword, newFirstName, newLastName, newEmail) > 0) {
            // call completion, invalid input
            completion(nil, nil, nil)
        }
        
        // create json of user data in dictionary
        let json = ["newUsername":"\(newUsername)", "oldPassword":"\(oldPassword)", "newPassword":"\(newPassword)", "newFirstName":"\(newFirstName)", "newLastName":"\(newLastName)", "newEmail":"\(newEmail)", "newGroupId":"\(newGroupId)"]
        let body = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create request
        let requestURL = URL(string: "\(SERVER_URL)/api/users/update?id=\(id)")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "PUT"
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
                completion(User(userJson: data!), response, error)
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
        let requestURL = URL(string: "\(SERVER_URL)/api/groups/group?id=\(id)")
        
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
                if let groupId = jsonObj["ssGroupId"], let name = jsonObj["name"], let adminId = jsonObj["adminId"], let dateCreated = jsonObj["dateCreated"], let location = jsonObj["location"], let locationDetail = jsonObj["locationDetail"] {
                    group = Group(groupId: groupId as! String, name: name as! String, adminId: adminId as! String, dateCreated: dateCreated as! String, location: location as! String, locationDetail: locationDetail as! String)
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
        let requestURL = URL(string: "\(SERVER_URL)/api/groups/allgroups")
        
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var groups: [Group]?
            
            // get json
            var json: [[String: Any]]!
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
                    if let groupId = item["ssGroupId"], let name = item["name"], let adminId = item["adminId"], let dateCreated = item["dateCreated"], let location = item["location"], let locationDetail = item["locationDetail"] {
                        groups!.append(Group(groupId: groupId as! String, name: name as! String, adminId: adminId as! String, dateCreated: dateCreated as! String, location: location as! String, locationDetail: locationDetail as! String))
                    }
                }
            }
            
            // complete the task
            completion(groups, response, error)
            
        }
        task.resume()
    }
    
    // GET group by adminId
    static func getGroup(with adminId: String, completion: @escaping (Group?, URLResponse?, Error?) -> Void) {
        let requestURL = URL(string: "\(SERVER_URL)/api/groups/groupwithadmin?adminId=\(adminId)")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var json: [String: Any]!
            do {
                if let d = data {
                    //print("data: \(String(data: d, encoding: .utf8))")
                    json = try JSONSerialization.jsonObject(with: d) as? [String: Any]
                    print("group json: \(json)")
                }
            }
            catch {
                print("ERROR GETTING GROUP")
            }
            
            // create group object
            if let group = json {
                if let id = group["ssGroupId"], let name = group["name"], let adminId = group["adminId"], let dateCreated = group["dateCreated"], let location = group["location"], let locationDetail = group["locationDetail"] {
                    let group = Group(groupId: id as! String, name: name as! String, adminId: adminId as! String, dateCreated: dateCreated as! String, location: location as! String, locationDetail: locationDetail as! String)
                    
                    completion(group, response, error)
                }
                else {
                    print("ERROR PARSING OWNER GROUP")
                }
            }
            else {
                // complete with nil group
                completion(nil, response, error)
            }
        }
        task.resume()
    }
    
    // POST group
    static func postGroup(name: String, adminId: String, password: String, location: String, locationDetail: String, completion: @escaping (Group?, URLResponse?, Error?) -> Void) {
        // create the request
        let requestURL = URL(string: "\(SERVER_URL)/api/groups/create")
        var request = URLRequest(url: requestURL!)
        
        // request properties
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // build body
        let bodyJson: [String: Any] = ["group":["name":"\(name)", "adminId":"\(adminId)", "location":"\(location)", "locationDetail":"\(locationDetail)"], "password":"\(password)"]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyJson, options: .prettyPrinted)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var json: [String: Any]!
            do {
                json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
            }
            catch {
                print("error creating item")
            }
            
            // get group from json
            var group: Group?
            if let groupId = json["ssGroupId"] as? String, let name = json["name"] as? String, let admin = json["admin"] as? String, let date = json["dateCreated"] as? String, let location = json["location"] as? String, let locationDetail = json["locationDetail"] as? String {
                group = Group(groupId: groupId, name: name, adminId: admin, dateCreated: date, location: location, locationDetail: locationDetail)
            }
            
            // complete the request
            completion(group, response, error)
        }
        task.resume()
    }
    
    /*
     *      ITEM METHODS
     */
    // Get all items in the database.
    static func getAllItems(completion: @escaping ([Item], URLResponse?, Error?) -> Void) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/items/allitems")
        
        // url request
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10    // seconds
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var items: [Item] = [Item]()
            
            var json: [[String: Any]]!
            do {
                if let d = data {
                    json = try JSONSerialization.jsonObject(with: d) as? [[String: Any]]
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
                    if let itemId = item["ssItemId"] as? String,
                        let groupId = item["groupId"] as? String,
                        let ownerId = item["ownerId"] as? String,
                        let name = item["name"] as? String,
                        let price = item["price"] as? String,
                        let condition = item["condition"] as? String,
                        let description = item["description"] as? String,
                        let thumbnail = item["thumbnail"] as? String,
                        let approved: Bool = item["approved"] as? Bool{
                        print("ADDED ITEM TO ARRAY")
                        
                        // check if item is already in bookmarked array. If so, put that item in place of the one retrieved to perserve the isBookmarked.
                        let item = Item(itemId: itemId, groupId: groupId, ownerId: ownerId, name: name, price: price, condition: condition, itemDescription: description, thumbnail: thumbnail, approved: approved)
                        
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
        
        let requestURL = URL(string: "\(SERVER_URL)/api/items/items?groupId=\(groupId)")
        
        // url request
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10    // seconds
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var items: [Item] = [Item]()
            
            var json: [[String: Any]]!
            do {
                if let d = data {
                    //print("itemdata: \(String(data: d, encoding: .utf8))")
                    json = try JSONSerialization.jsonObject(with: d) as? [[String: Any]]
                    //print("itemjson: \(json)")
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
                    if let itemId = item["ssItemId"] as? String,
                        let groupId = item["groupId"] as? String,
                        let ownerId = item["ownerId"] as? String,
                        let name = item["name"] as? String,
                        let price = item["price"] as? String,
                        let condition = item["condition"] as? String,
                        let description = item["description"] as? String,
                        let thumbnail = item["thumbnail"] as? String,
                        let approved = item["approved"] as? Bool {
                        print("ADDED ITEM TO ARRAY")
                        
                        // check if item is already in bookmarked array. If so, put that item in place of the one retrieved to perserve the isBookmarked.
                        let item = Item(itemId: itemId, groupId: groupId, ownerId: ownerId, name: name, price: price, condition: condition, itemDescription: description, thumbnail: thumbnail, approved: approved)
                        
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
    
    static func getApproved(with groupId: String, completion: @escaping ([Item], URLResponse?, Error?) -> Void) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/items/approved?groupId=\(groupId)")
        
        // url request
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10    // seconds
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var items: [Item] = [Item]()
            
            var json: [[String: Any]]!
            do {
                if let d = data {
                    //print("itemdata: \(String(data: d, encoding: .utf8))")
                    json = try JSONSerialization.jsonObject(with: d) as? [[String: Any]]
                    //print("itemjson: \(json)")
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
                    if let itemId = item["ssItemId"] as? String,
                        let groupId = item["groupId"] as? String,
                        let ownerId = item["ownerId"] as? String,
                        let name = item["name"] as? String,
                        let price = item["price"] as? String,
                        let condition = item["condition"] as? String,
                        let description = item["description"] as? String,
                        let thumbnail = item["thumbnail"] as? String,
                        let approved = item["approved"] as? Bool {
                        print("ADDED ITEM TO ARRAY")
                        
                        // check if item is already in bookmarked array. If so, put that item in place of the one retrieved to perserve the isBookmarked.
                        let item = Item(itemId: itemId, groupId: groupId, ownerId: ownerId, name: name, price: price, condition: condition, itemDescription: description, thumbnail: thumbnail, approved: approved)
                        
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
    static func post(item: Item, completion: @escaping (Item?, URLResponse?, Error?) -> Void) {
        
        // create the request
        let requestURL = URL(string: "\(SERVER_URL)/api/items/create")
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
            var json: [String: Any]!
            do {
                json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
            }
            catch {
                print("error creating item")
            }
            
            var item: Item?
            if let itemId = json["ssItemId"] as? String, let groupId = json["groupId"] as? String, let ownerId = json["ownerId"] as? String, let name = json["name"] as? String, let price = json["price"] as? String, let description = json["description"] as? String, let condition = json["condition"] as? String, let thumbnail = json["thumbnail"] as? String, let approved = json["approved"] as? Bool {
                item = Item(itemId: itemId, groupId: groupId, ownerId: ownerId, name: name, price: price, condition: condition, itemDescription: description, thumbnail: thumbnail, approved: approved)
            }
            
            // complete the request
            completion(item, response, error)
        }
        task.resume()
    }
    
    // update an item to a group
    static func put(item: Item, itemId: String, adminPassword: String, completion: @escaping (Item?, URLResponse?, Error?) -> Void) {
        // create the request
        let requestURL = URL(string: "\(SERVER_URL)/api/items/update?id=\(itemId)&adminPassword=\(adminPassword)")
        var request = URLRequest(url: requestURL!)
        
        // request properties
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        // build body
        let bodyJson: [String: String] = ["newName":"\(item.name)", "newPrice":"\(item.price)", "newCondition":"\(item.condition)", "newDescription":"\(item.itemDescription)", "newThumbnail":"\(item.thumbnail)", "approved":"\(item.approved)"]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyJson, options: .prettyPrinted)
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var json: [String: Any]!
            do {
                json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
            }
            catch {
                print("error creating item")
            }
            
            var item: Item?
            if let itemId = json["ssItemId"] as? String, let groupId = json["groupId"] as? String, let ownerId = json["ownerId"] as? String, let name = json["name"] as? String, let price = json["price"] as? String, let description = json["description"] as? String, let condition = json["condition"] as? String, let thumbnail = json["thumbnail"] as? String, let approved = json["approved"] as? Bool {
                item = Item(itemId: itemId, groupId: groupId, ownerId: ownerId, name: name, price: price, condition: condition, itemDescription: description, thumbnail: thumbnail, approved: approved)
            }
            
            // complete the request
            completion(item, response, error)
        }
        task.resume()
    }
    
    // delete an item
    static func deleteItem(id: String, password: String, completion: @escaping (Item?, URLResponse?, Error?) -> Void) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/items/delete?id=\(id)&password=\(password)")
        
        // url request
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "DELETE"
        request.timeoutInterval = 10    // seconds
        
        var item: Item?
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            var json: [String: Any]!
            do {
                if let d = data {
                    //print("itemdata: \(String(data: d, encoding: .utf8))")
                    json = try JSONSerialization.jsonObject(with: d) as? [String: Any]
                    //print("itemjson: \(json)")
                }
                else {
                    // return the empty array.
                    completion(item, response, error)
                }
            }
            catch {
                print("GET ITEM ERROR")
            }
            
            // Convert the recieved json into an array of items.
            if let jsonObj = json {
                // check the value of all the json data and add a new
                if let itemId = jsonObj["ssItemId"] as? String,
                    let groupId = jsonObj["groupId"] as? String,
                    let ownerId = jsonObj["ownerId"] as? String,
                    let name = jsonObj["name"] as? String,
                    let price = jsonObj["price"] as? String,
                    let condition = jsonObj["condition"] as? String,
                    let description = jsonObj["description"] as? String,
                    let thumbnail = jsonObj["thumbnail"] as? String,
                    let approved = jsonObj["approved"] as? Bool {
                    print("ADDED ITEM TO ARRAY")
                    
                    // check if item is already in bookmarked array. If so, put that item in place of the one retrieved to perserve the isBookmarked.
                    let deletedItem = Item(itemId: itemId, groupId: groupId, ownerId: ownerId, name: name, price: price, condition: condition, itemDescription: description, thumbnail: thumbnail, approved: approved)
                    
                    item = deletedItem
                }
                else {
                    print("ERROR GETTING A PARTICULAR ITEM")
                }
            }
            else {
                print()
                print("ERROR WITH ITEM ARRAY JSON")
            }
            
            // call the completion method, giving back the items and teh response
            completion(item, response, error)
            
        }
        task.resume()
    }
    
    // buy an item
    static func buy(itemId: String, userId: String, password: String, completion: @escaping (Item?, URLResponse?, Error?) -> Void) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/items/buyitem?id=\(itemId)&userId=\(userId)&password=\(password)")
        var request = URLRequest(url: requestURL!)
        
        request.httpMethod = "POST"
        
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            let res = String(data: data!, encoding: .utf8)
            print("Buy request response: \(res)")
            
            var json: [String: Any]!
            do {
                json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
            }
            catch {
                print("Error parsing Item from BUY")
            }
            
            // parse json
            var item: Item?
            if let jsonObj = json {
                if let itemId = jsonObj["ssItemId"] as? String,
                    let groupId = jsonObj["groupId"] as? String,
                    let ownerId = jsonObj["ownerId"] as? String,
                    let name = jsonObj["name"] as? String,
                    let price = jsonObj["price"] as? String,
                    let condition = jsonObj["condition"] as? String,
                    let description = jsonObj["description"] as? String,
                    let thumbnail = jsonObj["thumbnail"] as? String,
                    let approved = jsonObj["approved"] as? Bool {
                    
                    item = Item(itemId: itemId, groupId: groupId, ownerId: ownerId, name: name, price: price, condition: condition, itemDescription: description, thumbnail: thumbnail, approved: approved)
                }
            }
            
            completion(item, response, error)
        }
        task.resume()
    }
    
    /*
     *  Bookmarks method
     */
    static func getBookmarks(userId: String, password: String, completion: @escaping ([Item: String]?, URLResponse?, Error?) -> Void) {
        let requestURL = URL(string: "\(SERVER_URL)/api/bookmarks/bookmarks?userId=\(userId)&password=\(password)")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            var json: [[String: Any]]!
            if let d = data {
                do {
                    //print("bookmark data: \(String(data: d, encoding: .utf8))")
                    let res = response as? HTTPURLResponse
                    print("response: \(res?.statusCode)")
                    json = try JSONSerialization.jsonObject(with: d) as? [[String: Any]]
                }
                catch {
                    print("ERROR CONVERTING BOOKMARK JSON")
                }
            }
            else {
                print("BOOKMARK DATA NIL")
            }
            
            var bookmarks = [Item: String]()
            // parse Json into Bookmark dictionary.
            if let bookmarkArray = json {
                for bookmark in bookmarkArray {
                    if let bookmarkId = bookmark["bookmarkId"] as? String, let itemDict = bookmark["item"] as? [String: Any] {
                        
                        
                        let item = Item(itemId: itemDict["ssItemId"] as! String, groupId: itemDict["groupId"] as! String, ownerId: itemDict["ownerId"] as! String, name: itemDict["name"] as! String, price: itemDict["price"] as! String, condition: itemDict["condition"] as! String, itemDescription: itemDict["description"] as! String, thumbnail: itemDict["thumbnail"] as! String, approved: itemDict["approved"] as! Bool)
                        bookmarks[item] = bookmarkId
                    }
                    else {
                        print("ERROR PARSING BOOKMARK DICTIONARY")
                    }
                }
            }
            
            // completion
            completion(bookmarks, response, error)
        }
        task.resume()
    }
    
    static func postBookmark(userId: String, itemId: String, completion: @escaping ((bookmarkId: String?, itemId: String?, userId: String?), URLResponse?, Error?) -> Void) {
        
        // create the request
        let requestURL = URL(string: "\(SERVER_URL)/api/bookmarks/create?userId=\(userId)&itemId=\(itemId)")
        var request = URLRequest(url: requestURL!)
        
        // request properties
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var json: [String: Any]!
            do {
                json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
            }
            catch {
                print("error parsing resulting json")
            }
            
            
            var bookmarkId: String?
            var itemId: String?
            var userId: String?
            // create the bookmark
            if let jsonObj = json {
                bookmarkId = jsonObj["ssBookmarkId"] as? String
                itemId = jsonObj["itemId"] as? String
                userId = jsonObj["userId"] as? String
            }
            
            // completiton
            completion((bookmarkId, itemId, userId), response, error)
        }
        task.resume()
    }
    
    static func deleteBookmark(bookmarkId: String, completion: @escaping ((bookmarkId: String?, userId: String?, itemId: String?), URLResponse?, Error?) -> Void) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/bookmarks/delete?id=\(bookmarkId)")
        var request = URLRequest(url: requestURL!)
        
        request.httpMethod = "DELETE"
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            var json: [String: String]!
            do {
                json = try JSONSerialization.jsonObject(with: data!) as? [String: String]
            }
            catch {
                print("Error parsing bookmark")
            }
            
            var bookmarkId: String?
            var itemId: String?
            var userId: String?
            if let jsonObj = json {
                bookmarkId = jsonObj["ssBookmarkId"]
                itemId = jsonObj["itemId"]
                userId = jsonObj["userId"]
            }
            
            // completion
            completion((bookmarkId, userId, itemId), response, error)
        }
        task.resume()
    }
    
    // get messages for an Item
    static func getMessages(itemId: String, completion: @escaping ([Message], URLResponse?, Error?) -> Void) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/chat/messages?itemId=\(itemId)")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            let statusCode = (response as! HTTPURLResponse).statusCode
            if statusCode != 200 {
                print("Get Messages status: \(statusCode)")
                completion([Message](), response, error)
                return
            }
            
            let json = try! JSONSerialization.jsonObject(with: data!) as! [[String: Any]]
            
            var messages = [Message]()
            for message in json {
                if let msg = Message(data: try! JSONSerialization.data(withJSONObject: message)) {
                    messages.append(msg)
                }
            }
            
            // complete
            completion(messages, response, error)
        }
        task.resume()
    }
    
    static func postMessage(posterId: String, posterPassword: String, itemId: String, text: String, completion: @escaping (Message?, URLResponse?, Error?) -> Void) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/chat/create?posterId=\(posterId)&password=\(posterPassword)")
        var request = URLRequest(url: requestURL!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
        let body = ["itemId":"\(itemId)", "body":"\(text)"]
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            let statusCode = (response as! HTTPURLResponse).statusCode
            if statusCode != 200 {
                print("POST message status: \(statusCode)")
                completion(nil, response, error)
                return
            }
            
            completion(Message(data: data), response, error)
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


