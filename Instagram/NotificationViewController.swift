//
//  NotificationViewController.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import UIKit

class NotificationViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    private var viewModels = [NotificationCellType]()
    private var models = [IGNotification]()
    
    private let noActivityLabel:UILabel = {
        let label = UILabel()
        label.text = "No Notifications"
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
        
    }()
    
    private let tableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(FollowNotificationTableViewCell.self, forCellReuseIdentifier: FollowNotificationTableViewCell.identifier)
        tableView.register(LikeNotificationTableViewCell.self, forCellReuseIdentifier: LikeNotificationTableViewCell.identifier)
        tableView.register(CommentNotificationTableViewCell.self, forCellReuseIdentifier: CommentNotificationTableViewCell.identifier)
        
        tableView.isHidden = true
        
        return tableView
        
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Notification"
        
        view.backgroundColor = .systemBackground

        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(noActivityLabel)
        
        fetchNotification()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
        noActivityLabel.sizeToFit()
        noActivityLabel.center = view.center
    }
    
    private func fetchNotification(){
        NotificationManager.shared.getNotifications { [weak self] models in
            DispatchQueue.main.async{
                self?.models = models
                self?.createViewModels()
            }
        }
        
    }
        
    private func createViewModels (){
        
        models.forEach { notification in
            guard let type = NotificationManager.NotificationType(rawValue: notification.notificationType), let profilePictureUrl = URL(string: notification.profilePictureUrlString) else {
                return
            }
            let username = notification.username
            let date = notification.dateString
            switch type {
            case .like:
                guard let postUrl = URL(string: notification.PostUrl ?? "") else {return}
                viewModels.append(.like(viewModel: LikeNotificationCellViewModel(username: username, profilePictureUrl: profilePictureUrl, postUrl: postUrl, dateString: date)))
                
                
            case .follow:
                
                viewModels.append(.follow(viewModel: FollowNotificationCellViewModel(
                    username: username,
                    profilePictureUrl: profilePictureUrl,
                    isCurrentUserFollowing: false,
                    dateString: date)))
                
                
                
            case .comment:
                
                guard let postUrl = URL(string: notification.PostUrl ?? "") else {return}
                viewModels.append(.comment(viewModel: CommentNotificationCellViewModel(username: username, profilePictureUrl: profilePictureUrl, postUrl: postUrl, dateString: date )))
                
                
            }
        }
        
        noActivityLabel.isHidden = !viewModels.isEmpty
        tableView.isHidden = viewModels.isEmpty
        tableView.reloadData()
        
    }
    
    // MARK: - TableView
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellType = viewModels[indexPath.row]
        
        switch cellType {
        case .comment(let viewModel):
            let cell = tableView.dequeueReusableCell(withIdentifier: CommentNotificationTableViewCell.identifier) as! CommentNotificationTableViewCell
            cell.configure(with:viewModel)
            cell.delegate = self
            return cell
        case .follow(let viewModel):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: FollowNotificationTableViewCell.identifier) as! FollowNotificationTableViewCell
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        case .like(let viewModel):
            
            let cell = tableView.dequeueReusableCell(withIdentifier: LikeNotificationTableViewCell.identifier) as! LikeNotificationTableViewCell
            cell.configure(with: viewModel)
            cell.delegate = self
            return cell
        }
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cellType = viewModels[indexPath.row]
        var username:String
        switch cellType {
        case .like(let viewModel):
            username = viewModel.username
        case .comment(let viewModel):
            username = viewModel.username
        case .follow(let viewModel):
            username = viewModel.username
        }
        
        DatabaseManager.shared.findUser(username: username) {[weak self] user in
            guard let user = user else {
                let alert = UIAlertController(title: "Oops~", message: "Cannot open user profile", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
                self?.present(alert, animated: true)
                return
                
            }
            DispatchQueue.main.async {
                let vc = ProfileViewController(user: user)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
}

// MARK: - Actions
extension NotificationViewController:FollowNotificationTableViewCellDelegate,CommentNotificationTableViewCellDelegate,LikeNotificationTableViewCellDelegate {
    func CommentNotificationTableViewCellDidTapPost(_ cell: CommentNotificationTableViewCell, didTapPostWith viewModel: CommentNotificationCellViewModel) {
        
        
        guard let index = viewModels.firstIndex(where: {
            switch $0 {
            case .follow, .like:
                return false
            case .comment(let current):
                return current == viewModel
            }
        }) else {return}
        
        //find post by id
        openPost(with: index, username: viewModel.username)
        
    }
    
    func LikeNotificationTableViewCellDidTapPost(_ cell: LikeNotificationTableViewCell, didTapPostwith viewModel: LikeNotificationCellViewModel) {
        
        guard let index = viewModels.firstIndex(where: {
            switch $0 {
            case .follow, .comment:
                return false
            case .like(let current):
                return current == viewModel
            }
        }) else {return}
        
        //find post by id
        
        openPost(with: index, username: viewModel.username)
    }
    
    func FollowNotificationTableViewCellDidTapFollowButton(_ cell: FollowNotificationTableViewCell, didTapButton isFollowing: Bool, with viewModel: FollowNotificationCellViewModel) {
        
        let username = viewModel.username
        DatabaseManager.shared.updateRelationship(state: isFollowing ? .follow : .unfollow, for: username) { [weak self] success in
            print(success)
        }
        
    }
    
    
    func openPost(with index:Int, username:String) {
        guard  index < models.count else {return}
        let model = models[index]
        guard let postID = model.postId else {return}
        // Find post by id from target user
        DatabaseManager.shared.getPost(with: postID, from: username) { [weak self] post in
            
            DispatchQueue.main.async{
                guard let post = post else {return}
                let vc = PostViewController(post: post)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    
}
