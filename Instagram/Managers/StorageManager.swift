//
//  StorageManager.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private init (){}
    
    let storage = Storage.storage().reference()
    
    
    public func uploadPost(id:String, data:Data?, completion: @escaping (Bool) -> Void) {
        guard let data = data, let username = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return}
        storage.child("\(username)/posts/\(id).png").putData(data) { _, error in
            completion(error == nil)
        }
    }
    
    public func uploadProfilePicture(username: String, data:Data?, completion: @escaping (Bool) -> Void) {
        guard let data = data else {
            completion(false)
            return}
        storage.child("\(username)/profile_picture.png").putData(data) { _, error in
            completion(error == nil)
        }
    }
    
}
