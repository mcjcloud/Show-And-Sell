//
//  Message.swift
//  Show And Sell
//
//  Created by Brayden Cloud on 1/18/17.
//  Copyright © 2017 Brayden Cloud. All rights reserved.
//

import Foundation

class Message: NSObject {
    
    var messageId: String
    var itemId: String
    var posterId: String
    var posterName: String
    var adminId: String
    var adminName: String
    var datePosted: String
    var body: String
    
    init?(data messageJson: Data?) {
        
        if let data = messageJson {
            
            var json: [String: Any]!
            do {
                json = try JSONSerialization.jsonObject(with: data) as! [String : Any]
            }
            catch {
                return nil
            }
            
            if let messId = json["ssMessageId"] as? String,
                let itId = json["itemId"] as? String,
                let postId = json["posterId"] as? String,
                let postName = json["posterName"] as? String,
                let adminId = json["adminId"] as? String,
                let adminName = json["adminName"] as? String,
                let date = json["datePosted"] as? String,
                let bod = json["body"] as? String {
                
                self.messageId = messId
                self.itemId = itId
                self.posterId = postId
                self.posterName = postName
                self.adminId = adminId
                self.adminName = adminName
                self.datePosted = date
                self.body = bod
                
                super.init()
            }
            else {
                return nil
            }
        }
        else {
            return nil
        }
    }
    
    init(messageId: String, itemId: String, posterId: String, posterName: String, adminId: String, adminName: String, datePosted: String, body: String) {
        self.messageId = messageId
        self.itemId = itemId
        self.posterId = posterId
        self.posterName = posterName
        self.adminId = adminId
        self.adminName = adminName
        self.datePosted = datePosted
        self.body = body
    }
    
    // get array of Message from json
    static func messageArray(with messageJson: Data?) -> [Message] {
        var result = [Message]()
        
        if let data = messageJson {
            var json: [[String: Any]]!
            do {
                json = try JSONSerialization.jsonObject(with: data) as? [[String: Any]]
            }
            catch {
                return result
            }
            
            for message in json {
                if let msg = Message(data: try! JSONSerialization.data(withJSONObject: message)) {
                    result.append(msg)
                }
            }
        }
        
        // return result
        return result
    }
}
