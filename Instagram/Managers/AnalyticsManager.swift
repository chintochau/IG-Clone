//
//  AnalyticsManager.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import Foundation
import FirebaseAnalytics

final class AnalyticsManager {
    static let shared = AnalyticsManager()
    
    private init (){}
    
    
    func logEvent() {
        Analytics.logEvent("", parameters: [ : ])
    }
}
