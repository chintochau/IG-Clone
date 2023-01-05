//
//  DatabaseManager.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import Foundation
import FirebaseFirestore

final class DatabaseManager {
    static let shared = DatabaseManager()
    
    private init (){}
    
    let database = Firestore.firestore()
    
    

    
    public func createUser(newUser: User, completion: @escaping (Bool) -> Void){
        
        let reference = database.document("users/\(newUser.username)")
        guard let data = newUser.asDictionary() else {
            completion(false)
            return
        }
        
        reference.setData(data) { error in
            completion(error == nil)
        }
    }
    
    public func createPost(newPost: Post, completion: @escaping (Bool) -> Void){
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return}
        
        let reference = database.document("users/\(username)/posts/\(newPost.id)")
        
        guard let data = newPost.asDictionary() else {
            completion(false)
            return
        }
        
        reference.setData(data) { error in
            completion(error == nil)
        }
    }
    
    public func findUser(with email: String, completion: @escaping (User?) -> Void){
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents, error == nil else {
                completion(nil)
                return
            }
            let userData = users.compactMap { $0.data() }
            let myUsers = userData.compactMap({User(with: $0)})
            
            let user = myUsers.first(where: {$0.email == email})
            completion(user)
        }
    }
    
    public func posts(for username:String, completion: @escaping (Result<[Post], Error>) -> Void){
        let ref = database.collection("users").document(username).collection("posts")
        ref.getDocuments { snapshot, error in
            guard let documents = snapshot?.documents, error == nil else {
                return}
            let postsData = documents.compactMap{ $0.data() }
            let posts = postsData.compactMap {Post(with: $0)}
            
            completion(.success(posts))
        }
    }
    
}
