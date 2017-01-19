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
    var datePosted: String
    var body: String
    
    init?(data messageJson: Data?) {
        
        if let data = messageJson {
            var json: [String: Any] = try! JSONSerialization.jsonObject(with: data) as! [String : Any]
            
            if let messId = json["ssMessageId"] as? String,
                let itId = json["itemId"] as? String,
                let postId = json["posterId"] as? String,
                let postName = json["posterName"] as? String,
                let date = json["datePosted"] as? String,
                let bod = json["body"] as? String {
                
                self.messageId = messId
                self.itemId = itId
                self.posterId = postId
                self.posterName = postName
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
    
    init(messageId: String, itemId: String, posterId: String, posterName: String, datePosted: String, body: String) {
        self.messageId = messageId
        self.itemId = itemId
        self.posterId = posterId
        self.posterName = posterName
        self.datePosted = datePosted
        self.body = body
    }
}
