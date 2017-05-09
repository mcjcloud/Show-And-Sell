//
//  HttpRequestManager.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 9/23/16.
//  Copyright © 2016 Brayden Cloud. All rights reserved.
//
//  Defines a set of functions to be be used to make URL requests and manage user, group and item models from the database
//

import Foundation

class HttpRequestManager {
    public static let SERVER_URL = "http://68.248.214.70:8080/showandsell"
    //public static let SERVER_URL = "http://192.168.1.107:8080/showandsell"
    static let requestTimeout = 20.0
    
    // MARK: User
    
    // get a user with user id and password
    static func user(withId id: String, andPassword password: String, completion: @escaping (User?, URLResponse?, Error?) -> Void) {
        
        // the url to make the URLRequest to
        let requestURL = URL(string: "\(SERVER_URL)/api/users/userbyuserid?id=\(id)&password=\(password)")
        
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        
        // make the request and call the completion method with the new user
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            completion(User(data: data), response, error)
        }
        task.resume()
    }
    // get a user with email and password
    static func user(withEmail email: String, andPassword password: String, completion: @escaping (User?, URLResponse?, Error?) -> Void) {
        
        // the request URL
        let requestURL = URL(string: "\(SERVER_URL)/api/users/userbyemail?email=\(email)&password=\(password)")
        
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        
        // make the request for the user, and return it in the completion method
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
           completion(User(data: data), response, error)
        }
        task.resume()
    }
    
    // POST google user and 
    static func googleUser(email: String, userId: String, firstName: String, lastName: String, completion: @escaping (User?, URLResponse?, Error?) -> Void) {
        
        // create the request
        let requestURL = URL(string: "\(SERVER_URL)/api/users/googleuser")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = requestTimeout
        
        // create the http body
        let json = ["email":"\(email)", "userId":"\(userId)", "firstName":"\(firstName)", "lastName":"\(lastName)"]
        let body = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        request.httpBody = body
        
        // make request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            completion(User(data: data), response, error)
        }
        task.resume()
    }
    
    // create user request
    static func post(user: User, completion: @escaping (User?, URLResponse?, Error?) -> Void) {
        
        // instance variables
        let email = user.email
        let password = user.password
        let firstName = user.firstName
        let lastName = user.lastName
        
        // check validity of data
        let pattern = "[a-zA-Z0-9]"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        if !(numberOfMatches(withRegex: regex, andStrings: password, firstName, lastName, email) > 0) {
            // call completion, invalid input
            completion(nil, nil, nil)
        }
        
        // create json of user data in dictionary
        let json = ["email":"\(email)", "password":"\(password)", "firstName":"\(firstName)", "lastName":"\(lastName)"]
        let body = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create request
        let requestURL = URL(string: "\(SERVER_URL)/api/users/create")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = requestTimeout
        
        // a JSON of the user to be created.
        request.httpBody = body
        
        // make the request, call the completion method
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // call the completion, creating a new user object for the user that was just created.
            completion(User(data: data), response, error)
        }
        task.resume()
    }
    
    // update user
    static func put(user: User, currentPassword: String, completion: @escaping (User?, URLResponse?, Error?) -> Void) {
        
        // instance variables
        let id = user.userId
        let newEmail = user.email
        let newPassword = user.password
        let newFirstName = user.firstName
        let newLastName = user.lastName
        let newGroupId = user.groupId
        
        // check validity of data
        let pattern = "[a-zA-Z0-9]"
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        if !(numberOfMatches(withRegex: regex, andStrings: newPassword, newFirstName, newLastName, newEmail) > 0) {
            // call completion, invalid input
            completion(nil, nil, nil)
        }
        
        // create json of user data in dictionary
        let json = ["newEmail":"\(newEmail)", "oldPassword":"\(currentPassword)", "newPassword":"\(newPassword)", "newFirstName":"\(newFirstName)", "newLastName":"\(newLastName)", "newGroupId":"\(newGroupId)"]
        let body = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
        
        // create request
        let requestURL = URL(string: "\(SERVER_URL)/api/users/update?id=\(id)")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "PUT"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = requestTimeout
        
        // a JSON of the user to be created.
        request.httpBody = body
        
        // make the request, call the completion method
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // call the completion, creating a new user object for the user that was just created.
            completion(User(data: data), response, error)
        }
        task.resume()
    }
    
    // MARK: Group
    
    // get a group by its group id.
    static func group(withId id: String, completion: @escaping (Group?, URLResponse?, Error?) -> Void) {
        
        // build request
        let requestURL = URL(string: "\(SERVER_URL)/api/groups/group?id=\(id)")
        
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        
        // create tast
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // complete the task
            completion(Group(data: data), response, error)
        }
        task.resume()
    }
    
    // get all groups
    static func groups(completion: @escaping ([Group], URLResponse?, Error?) -> Void) {
        
        // setup request
        let requestURL = URL(string: "\(SERVER_URL)/api/groups/allgroups")
        
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            // complete the task
            completion(Group.groupArray(with: data), response, error)
            
        }
        task.resume()
    }
    
    // GET group by adminId
    static func group(withAdminId id: String, completion: @escaping (Group?, URLResponse?, Error?) -> Void) {
        let requestURL = URL(string: "\(SERVER_URL)/api/groups/groupwithadmin?adminId=\(id)")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // complete
            completion(Group(data: data), response, error)
        }
        task.resume()
    }
    
    // GET groups within a certain radius of the given coordinates
    static func groups(inRadius r: Float, fromLatitude lat: Double, longitude long: Double, completion: @escaping ([Group], URLResponse?, Error?) -> Void) {
        // create request
        let requestURL = URL(string: "\(SERVER_URL)/api/groups/groupsinradius?radius=\(r)&latitude=\(lat)&longitude=\(long)")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            completion(Group.groupArray(with: data), response, error)
        }
        task.resume()
    }
    
    // GET n closest groups to given coordinates
    static func groups(n: Int, closestToLatitude lat: Double, longitude long: Double, completion: @escaping ([Group], URLResponse?, Error?) -> Void) {
        // create request
        let requestURL = URL(string: "\(SERVER_URL)/api/groups/closestgroups?n=\(n)&latitude=\(lat)&longitude=\(long)")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            completion(Group.groupArray(with: data), response, error)
        }
        task.resume()
    }
    
    // GET search for groups including string
    static func groups(matching: String, completion: @escaping ([Group], URLResponse?, Error?) -> Void) {
        let requestURL = URL(string: "\(SERVER_URL)/api/groups/search?name=\(matching)")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            completion(Group.groupArray(with: data), response, error)
        }
        task.resume()
    }
    
    // GET a rating
    static func rating(forGroupId groupId: String, andUserId userId: String, completion: @escaping (Int?, URLResponse?, Error?) -> Void) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/groups/rating?groupId=\(groupId)&userId=\(userId)")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            var value: Int? = nil
            if let data = data, (response as? HTTPURLResponse)?.statusCode == 200 {
                var json: [String: Any]!
                do {
                    json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                    value = json["rating"] as? Int
                } catch { }
            }
            
            completion(value, response, error)
        }
        task.resume()
    }
    
    // POST rate a group
    static func rateGroup(withId id: String, rating: Int, userId: String, password: String, completion: @escaping (Float?, URLResponse?, Error?) -> Void) {
        let requestURL = URL(string: "\(SERVER_URL)/api/groups/rategroup?id=\(id)&rating=\(rating)&userId=\(userId)&password=\(password)")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "POST"
        request.timeoutInterval = requestTimeout
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            var value: Float? = nil
            if let data = data, (response as? HTTPURLResponse)?.statusCode == 200 {
                var json: [String: Any]!
                do {
                    json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
                    value = json["rating"] as? Float
                }
                catch { }
            }
            
            // return the new rating
            completion(value, response, error)
        }
        task.resume()
    }
    
    // POST donate money to group
    static func donateToGroup(withId groupId: String, userId: String, password: String, paymentDetails: (token: String, nonce: String, amount: Double), completion: @escaping ([String: Any], URLResponse?, Error?) -> Void) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/groups/donatetogroup?id=\(groupId)&userId=\(userId)&password=\(password)")
        var request = URLRequest(url: requestURL!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = requestTimeout
        
        // create request body
        let bodyJson: [String: Any] = ["token":paymentDetails.token, "paymentMethodNonce":paymentDetails.nonce, "amount":paymentDetails.amount]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyJson, options: .prettyPrinted)
        
        // create task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            var json: [String: Any]!
            do {
                json = try JSONSerialization.jsonObject(with: data ?? "".data(using: .utf8)!) as! [String: Any]
            }
            catch {
                print("error with returned data from donate")
                completion([String: Any](), response, error)
            }
            
            if json != nil {
                completion(json, response, error)
            }
            else {
                completion([String: Any](), response, error)
            }
        }
        task.resume()
    }
    
    // POST group
    static func post(group: Group, password: String, completion: @escaping (Group?, URLResponse?, Error?) -> Void) {
        
        // create the request
        let requestURL = URL(string: "\(SERVER_URL)/api/groups/create")
        var request = URLRequest(url: requestURL!)
        
        // request properties
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = requestTimeout
        
        // build body
        let bodyJson: [String: Any] = ["group":["name":"\(group.name)", "adminId":"\(group.adminId)", "address":"\(group.address)", "latitude":group.latitude, "longitude":group.longitude, "locationDetail":"\(group.locationDetail)"], "password":"\(password)"]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyJson, options: .prettyPrinted)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // complete the request
            completion(Group(data: data), response, error)
        }
        task.resume()
    }
    
    // MARK: Item
    
    // get an item by its ID
    static func item(id: String, completion: @escaping (Item?, URLResponse?, Error?) -> Void) {
        let requestURL = URL(string: "\(SERVER_URL)/api/items/item?id=\(id)")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            completion(Item(data: data), response, error)
        }
        task.resume()
    }
    
    // Get all items in the database.
    static func items(completion: @escaping ([Item], URLResponse?, Error?) -> Void) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/items/allitems")
        
        // url request
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // call the completion method, giving back the items and teh response
            completion(Item.itemArray(with: data), response, error)
        }
        task.resume()
    }
    
    // get items from a particular group
    static func items(withGroupId id: String, completion: @escaping ([Item], URLResponse?, Error?) -> Void) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/items/items?groupId=\(id)")
        
        // url request
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            // call the completion method, giving back the items and teh response
            completion(Item.itemArray(with: data), response, error)
            
        }
        task.resume()
    }
    
    // get all approved items in a given range
    static func allApproved(inRange start: Int, to end: Int, completion: @escaping ([Item], URLResponse?, Error?) -> Void) {
        let requestURL = URL(string: "\(SERVER_URL)/api/items/allapprovedinrange?start=\(start)&end=\(end)")
        
        // request
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // call the completion handler
            completion(Item.approvedArray(with: data), response, error)
        }
        task.resume()
    }
    
    // get all approved items within a group
    static func approvedItems(withGroupId id: String, completion: @escaping ([Item], URLResponse?, Error?) -> Void) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/items/approved?groupId=\(id)")
        
        // url request
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // call the completion method, giving back the items and teh response
            completion(Item.approvedArray(with: data), response, error)
            
        }
        task.resume()
    }
    
    // get all approved items in a group within a certain range
    static func approvedItems(withGroupId id: String, inRange start: Int, to end: Int, completion: @escaping ([Item], URLResponse?, Error?) -> Void) {
        let requestURL = URL(string: "\(SERVER_URL)/api/items/approvedinrange?groupId=\(id)&start=\(start)&end=\(end)")
        
        // url request
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // call the completion method, giving back the items and teh response
            completion(Item.approvedArray(with: data), response, error)
            
        }
        task.resume()
    }
    
    // get a purchase token
    static func paymentToken(completion: @escaping (String?) -> Void) {
        let requestURL = URL(string: "\(SERVER_URL)/api/items/paymenttoken")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        
        // make request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let d = data {
                completion(String(data: d, encoding: .utf8))
            }
            else {
                completion(nil)
            }
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
        request.timeoutInterval = requestTimeout
        
        // build body
        let bodyJson: [String: String] = ["groupId":"\(item.groupId)", "ownerId":"\(item.ownerId)", "name":"\(item.name)", "price":"\(item.price)", "condition":"\(item.condition)", "description":"\(item.itemDescription)", "thumbnail":"\(item.thumbnail)"]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyJson, options: .prettyPrinted)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let e = error {
                print("error: \(e)")
                completion(nil, nil, nil)
            }
            
            // complete the request
            completion(Item(data: data), response, error)
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
        request.timeoutInterval = requestTimeout
        
        // build body
        let bodyJson: [String: String] = ["newName":"\(item.name)", "newPrice":"\(item.price)", "newCondition":"\(item.condition)", "newDescription":"\(item.itemDescription)", "newThumbnail":"\(item.thumbnail)", "approved":"\(item.approved)"]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyJson, options: .prettyPrinted)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // complete the request
            completion(Item(data: data), response, error)
        }
        task.resume()
    }
    
    // delete an item
    static func delete(itemWithId id: String, password: String, completion: @escaping (Item?, URLResponse?, Error?) -> Void) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/items/delete?id=\(id)&password=\(password)")
        
        // url request
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "DELETE"
        request.timeoutInterval = requestTimeout
        
        // create task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // call the completion method, giving back the items and teh response
            completion(Item(data: data), response, error)
            
        }
        task.resume()
    }
    
    // buy an item
    static func buy(itemWithId id: String, userId: String, password: String, paymentDetails: (token: String, nonce: String, amount: Double), completion: @escaping ([String: Any], URLResponse?, Error?) -> Void) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/items/buyitem?id=\(id)&userId=\(userId)&password=\(password)")
        var request = URLRequest(url: requestURL!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = requestTimeout
        
        // create request body
        let bodyJson: [String: Any] = ["token":paymentDetails.token, "paymentMethodNonce":paymentDetails.nonce, "amount":paymentDetails.amount]
        request.httpBody = try! JSONSerialization.data(withJSONObject: bodyJson, options: .prettyPrinted)
        
        // create task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            var json: [String: Any]!
            do {
                json = try JSONSerialization.jsonObject(with: data ?? "".data(using: .utf8)!) as! [String: Any]
            }
            catch {
                print("error with returned data from BUY")
                completion([String: Any](), response, error)
            }
            
            completion(json, response, error)
        }
        task.resume()
    }
    
    // GET the full size image for an item
    static func fullImage(forId id: String, completion: @escaping (String?) -> Void) {
        // TODO: implement after fixed server side
    }
    
    // MARK: Bookmark
    
    // get bookmarks for a user with the given ID
    static func bookmarks(forUserWithId id: String, password: String, completion: @escaping ([Item: String]?, URLResponse?, Error?) -> Void) {
        let requestURL = URL(string: "\(SERVER_URL)/api/bookmarks/bookmarks?userId=\(id)&password=\(password)")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        
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
    
    // post a bookmark to the server
    static func post(bookmarkForUserWithId id: String, itemId: String, completion: @escaping ((bookmarkId: String?, itemId: String?, userId: String?), URLResponse?, Error?) -> Void) {
        
        // create the request
        let requestURL = URL(string: "\(SERVER_URL)/api/bookmarks/create?userId=\(id)&itemId=\(itemId)")
        var request = URLRequest(url: requestURL!)
        
        // request properties
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = requestTimeout
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            var json: [String: Any]!
            do {
                json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
            }
            catch {
                print("error parsing resulting json")
                completion((nil, nil, nil), response, error)
            }
            
            if let bookmarkId = json["ssBookmarkId"] as? String,
                let itemId = json["itemId"] as? String,
                let userId = json["userId"] as? String {
                
                // completion
                completion((bookmarkId, userId, itemId), response, error)
            }
            else {
                completion((nil, nil, nil), response, error)
            }
        }
        task.resume()
    }
    
    // delete a bookmark with the given bookmark id
    static func delete(bookmarkWithId id: String, completion: (((bookmarkId: String?, userId: String?, itemId: String?), URLResponse?, Error?) -> Void)?) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/bookmarks/delete?id=\(id)")
        var request = URLRequest(url: requestURL!)
        
        request.httpMethod = "DELETE"
        request.timeoutInterval = requestTimeout
        
        let session = URLSession.shared
        let task = session.dataTask(with: request) { data, response, error in
            
            var json: [String: Any]!
            do {
                json = try JSONSerialization.jsonObject(with: data!) as? [String: Any]
            }
            catch {
                print("Error parsing bookmark")
            }
            
            if let bookmarkId = json["ssBookmarkId"] as? String,
                let itemId = json["itemId"] as? String,
                let userId = json["userId"] as? String {
                
                // completion
                completion?((bookmarkId, userId, itemId), response, error)
            }
            else {
                completion?((nil, nil, nil), response, error)
            }
        
        }
        task.resume()
    }
    
    // get messages for an Item
    static func messages(forItemId id: String, completion: @escaping ([Message], URLResponse?, Error?) -> Void) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/chat/messages?itemId=\(id)")
        var request = URLRequest(url: requestURL!)
        request.httpMethod = "GET"
        request.timeoutInterval = requestTimeout
        
        // create task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // complete
            completion(Message.messageArray(with: data), response, error)
        }
        task.resume()
    }
    
    // post a message
    static func post(messageWithPosterId id: String, posterPassword: String, itemId: String, text: String, completion: @escaping (Message?, URLResponse?, Error?) -> Void) {
        
        let requestURL = URL(string: "\(SERVER_URL)/api/chat/create?posterId=\(id)&password=\(posterPassword)")
        var request = URLRequest(url: requestURL!)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = requestTimeout
        
        let body = ["itemId":"\(itemId)", "body":"\(text)"]
        request.httpBody = try! JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // complete
            completion(Message(data: data), response, error)
        }
        task.resume()
    }
    
    // MARK: Helper
    static func numberOfMatches(withRegex regex: NSRegularExpression, andStrings strings: String...) -> Int {
        var matchCount = 0
        for string in strings {
            if regex.numberOfMatches(in: string, options: [], range: NSRange(location: 0, length: string.characters.count)) > 0 {
                matchCount += 1
            }
        }
        
        return matchCount
    }
    
    static func encrypt(_ text: String) -> String {
        // Caesar shift +1
        var result = ""
        for char in text.utf16 {
            let u = UnicodeScalar(char + 1)!
            result += String(Character(u))
        }
        
        // base64 encode
        let resultData = result.data(using: .utf8)
        let encrypted = resultData!.base64EncodedString()
        
        // return encrypted
        return encrypted
    }
    
    static func decrypt(_ text: String) -> String {
        // convert from base64
        let data = Data(base64Encoded: text)
        var decrypted = ""
        if let data = data {
            let decodedString = String(data: data, encoding: .utf8)
            
            // caesar shift - 1
            for char in (decodedString ?? "").utf16 {
                let u = UnicodeScalar(char - 1)!
                decrypted += String(Character(u))
            }
        }
        
        // return the decoded string
        return decrypted
    }
}


