//
//  NotificationManager.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-06.
//

import Foundation

struct NotificationManager {
    static let shared = NotificationManager()

    
    enum NotificationType:Int {
        case like = 1
        case comment = 2
        case follow = 3
    }
    
    public func getNotifications(completion: @escaping ([IGNotification]) -> Void){
        DatabaseManager.shared.getNotifications(completion: completion)
        
    }
    
    
    public func create(notification:IGNotification, for username:String) {
        let identifier = notification.identifier
        guard let dictionary = notification.asDictionary() else {return}
        DatabaseManager.shared.insertNotification(identifier: identifier, data: dictionary, for: username)
        
        
    }
    
    static func newIdentifier() -> String{
        let date = Date()
        let number1 = Int.random(in: 1...1000)
        let number2 = Int.random(in: 1...1000)
        return "\(number1)_\(number2)_\(date.timeIntervalSince1970)"
    }
    
    
    
}
