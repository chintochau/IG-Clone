//
//  NotificationCellType.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-06.
//

import Foundation

enum NotificationCellType {
    case follow(viewModel: FollowNotificationCellViewModel)
    case like(viewModel: LikeNotificationCellViewModel)
    case comment(viewModel: CommentNotificationCellViewModel)
}
