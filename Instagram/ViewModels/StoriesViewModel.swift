//
//  File.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-10.
//

import Foundation
import UIKit

struct StoriesViewModel {
    let stories: [Story]
}

struct Story {
    let username: String
    let image: URL?
}
