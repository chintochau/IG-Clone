//
//  HomeFeedCelltype.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-03.
//

import Foundation

enum HomeFeedCellType {
    case poster(ViewModel:PosterCollectionViewCellViewModel)
    case post(ViewModel:PostCollectionViewCellViewModel)
    case actions(ViewModel:PostActionCollectionViewCellViewModel)
    case likeCount(ViewModel:PostLikesCollectionViewCellViewModel)
    case caption(ViewModel:PostCaptionCollectionViewCellViewModel)
    case timestamp(ViewModel:PostDateTimeCollectionViewCellViewModel)
}
