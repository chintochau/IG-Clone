//
//  Notification.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import Foundation

struct IGNotification:Codable {
    let identifier: String
    let notificationType: Int //1: like ,2: comment ,3: Follow
    let profilePictureUrlString:String
    let username:String
    let dateString: String
    // Follow/unfollow
    let isFollowing: Bool?
    //Like?comment
    let postId: String?
    let PostUrl: String?
    
}
