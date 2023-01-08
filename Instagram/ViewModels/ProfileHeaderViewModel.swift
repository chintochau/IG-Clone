//
//  ProfileHeaderViewModel.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-07.
//

import Foundation

enum ProfileButtonType {
    case edit
    case follow(isFollowing:Bool)
}

struct ProfileHeaderViewModel {
    let username:String?
    let profileUrl:URL?
    let postCount:Int
    let followerCount:Int
    let followingCount:Int
    let bio:String?
    let buttonType:ProfileButtonType
}
