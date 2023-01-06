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
    
    
    public func uploadPost(id:String, data:Data?, completion: @escaping (URL?) -> Void) {
        guard let data = data,
              let username = UserDefaults.standard.string(forKey: "username") else {return}
        let ref = storage.child("\(username)/posts/\(id).png")
        ref.putData(data) { _, error in
            ref.downloadURL { url, _ in
                completion(url)
            }
            
        }
    }
    
    /// get download URL for a post
    public func downloadURL(for post: Post, completion: @escaping (URL?) -> Void){
        guard let ref = post.storageReference else {
            completion(nil)
            return}
        storage.child(ref).downloadURL { url, error in
            completion(url)
        }
    }
    
    public func profilePictureURL(for username: String, completion: @escaping (URL?) -> Void){
        let ref = "\(username)/profile_picture.png"
        storage.child(ref).downloadURL { url, error in
            completion(url)
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
