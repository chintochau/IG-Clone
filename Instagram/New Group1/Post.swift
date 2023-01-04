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
    let likers:[String]
}
