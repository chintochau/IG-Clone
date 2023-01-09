//
//  SettingsModels.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-09.
//

import Foundation
import UIKit


struct SettingsSection{
    let title: String
    let options: [SettingOption]
}


struct SettingOption {
    let title: String
    let image: UIImage?
    let color: UIColor
    let handler:(() -> Void)
}
