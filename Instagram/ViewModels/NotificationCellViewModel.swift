//
//  NotificationCellViewModel.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-06.
//

import Foundation

struct LikeNotificationCellViewModel:Equatable {
    let username: String
    let profilePictureUrl: URL
    let postUrl:URL
    let dateString:String
}
struct FollowNotificationCellViewModel:Equatable {
    let username: String
    let profilePictureUrl: URL
    let isCurrentUserFollowing: Bool
    let dateString:String
}
struct CommentNotificationCellViewModel :Equatable{
    let username: String
    let profilePictureUrl: URL
    let postUrl:URL
    let dateString:String
}
