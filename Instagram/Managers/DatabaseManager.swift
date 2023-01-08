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
    
    /// find users with search query(usernamePrefix), used in explore view
    public func findUsers(with usernamePrefix: String, completion: @escaping ([User]) -> Void) {
        
            let ref = database.collection("users")
            ref.getDocuments { snapshot, error in
                guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }) , error == nil else {
                    completion([])
                    return
                }
                let subset = users.filter ({
                    $0.username.lowercased().hasPrefix(usernamePrefix.lowercased())
                })
                completion(subset)
            }
    }
    
    /// find post with username
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
    
    /// find user with email, used when creating account
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
    
    /// find user with uername
    public func findUser(username: String, completion: @escaping (User?) -> Void){
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents, error == nil else {
                completion(nil)
                return
            }
            let userData = users.compactMap { $0.data() }
            let myUsers = userData.compactMap({User(with: $0)})
            
            let user = myUsers.first(where: {$0.username == username})
            completion(user)
        }
    }
    
    public func explorePosts(completion: @escaping ([Post]) -> Void) {
        
        let ref = database.collection("users")
        ref.getDocuments { snapshot, error in
            guard let users = snapshot?.documents.compactMap({ User(with: $0.data()) }) , error == nil else {
 
                return
            }
            
            let group = DispatchGroup()
            var appregatePosts = [Post]()
            
            users.forEach{ user in
                let username = user.username
                let postRef = self.database.collection("users/\(username)/posts")
                group.enter()
                
                postRef.getDocuments { snapshot, error in
                    guard let posts = snapshot?.documents.compactMap({ Post(with: $0.data()) }) , error == nil else {
                        return
                    }
                    defer{
                        group.leave()
                    }
                    
                    appregatePosts.append(contentsOf:posts)
                }
                
            }
            
            group.notify(queue: .main){
                completion(appregatePosts)
            }
            
        }
        
    }
    
    
    public func getNotifications(completion: @escaping ([IGNotification]) -> Void){
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            completion([])
            return}
        let ref = database.collection("users").document(username).collection("notifications")
        ref.getDocuments { snapshot, error in
            guard let notifications = snapshot?.documents.compactMap({ IGNotification(with: $0.data()) }) , error == nil else {
                completion([])
                 return
            }
            
            completion(notifications)
            
        }
    }
    
    
    public func insertNotification(identifier: String, data: [String : Any], for username: String){
        let ref = database.collection("users").document(username).collection("notifications").document(identifier)
        ref.setData(data)
        
    }
    
    public func getPost(with identifier:String, from username:String, completion: @escaping (Post?) -> Void) {
        let ref = database.collection("users").document(username).collection("posts").document(identifier)

        ref.getDocument { snapshot, error in
            guard let data = snapshot?.data(), let post = Post(with: data),error == nil else {
                completion(nil)
                return}
            completion(post)
        }
    }
    
    enum RelationshipState {
        case follow
        case unfollow
    }
    
    public func updateRelationship(state: RelationshipState, for targetUsername:String, completion: @escaping (Bool) -> Void){
        
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return
        }
        
        let currentFollowing = database.collection("users").document(currentUsername).collection("following")
        
        let targetUserFollowers = database.collection("users").document(targetUsername).collection("followers")
        
        switch state {
        case .follow:
            //add for sender and receiver
            currentFollowing.document(targetUsername).setData(["valid":true])
            targetUserFollowers.document(currentUsername).setData(["valid":true])
            print("follow")
            completion(true)
        case .unfollow:
            // remove for sender and receiver
            currentFollowing.document(targetUsername).delete()
            targetUserFollowers.document(currentUsername).delete()
            print("unfollow")
            completion(true)
            
        }
        
    }
    
    public func getUserCounts(
        username: String,
        completion: @escaping ((followers: Int, following:Int, posts:Int)) -> Void) {
            let userRef = database.collection("users").document(username)
            var numbers = (followers:0,following:0,posts:0)
            
            let group = DispatchGroup()
            group.enter()
            userRef.collection("followers").getDocuments { snapshot, error in
                defer {group.leave()}
                guard let snapshot = snapshot else { return }
                numbers.followers = snapshot.count
            }
            
            group.enter()
            userRef.collection("following").getDocuments { snapshot, error in
                defer {group.leave()}
                guard let snapshot = snapshot else { return }
                numbers.following = snapshot.count
            }
            
            group.enter()
            userRef.collection("posts").getDocuments { snapshot, error in
                defer {group.leave()}
                guard let snapshot = snapshot else { return }
                numbers.posts = snapshot.count
            }
            
            group.notify(queue: .global()) {
                completion(numbers)
            }
            
        }
    
    public func isFollowing(targetUsername:String, completion: @escaping (Bool) -> Void) {
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {
            completion(false)
            return}
        let userRef = database.collection("users").document(targetUsername).collection("followers").document(currentUsername)
        
        userRef.getDocument { snapshot, error in
            completion(snapshot?.data() != nil)
        }
    }
    
    
    // MARK: - User Info
    /// get user info: name, bio, etc
    public func getUserInfo(username:String, completion: @escaping (UserInfo?) -> Void) {
        
        let userRef = database.collection("users").document(username).collection("information").document("basic")
        userRef.getDocument(completion: { snapshot, error in
            guard let data = snapshot?.data() else {
                completion(nil)
                return
            }
            completion(UserInfo(with: data))
        })
        
    }
    
    public func setUserInfo(userinfo:UserInfo, completion: @escaping (Bool) -> Void) {
        guard let username = UserDefaults.standard.string(forKey: "username"),
        let dictionary = userinfo.asDictionary() else {
            completion(false)
            return}
        
        let userRef = database.collection("users").document(username).collection("information").document("basic")
        userRef.setData(dictionary) { error in
            guard error == nil else {return}
            completion(true)
        }
    }
    
}
