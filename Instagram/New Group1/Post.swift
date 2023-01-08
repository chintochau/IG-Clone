//
//  Post.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import Foundation

struct Post:Codable {
    let id:String
    let caption:String
    let postedDate:String
    let postUrlString:String
    var likers:[String]
    
    var date:Date {
        return DateFormatter.formatter.date(from: postedDate) ?? Date()
    }
    
    var storageReference:String? {
        guard let username = UserDefaults.standard.string(forKey: "username") else {return nil}
        return "\(username)/posts/\(id).png"
    }
}
