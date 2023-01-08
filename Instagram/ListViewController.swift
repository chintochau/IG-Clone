//
//  ListViewController.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import UIKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    let tableView:UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(ListUserTableViewCell.self, forCellReuseIdentifier: ListUserTableViewCell.identifier)
        return tableView
    }()
    
    private var viewModel:[ListUserTableViewCellViewModel] = []
    
    enum ListType {
        case folowers(user:User)
        case following(user:User)
        case likers(username:[String])
        
        
        var title:String{
            switch self {
            case .folowers:
                return "Followers"
            case .following:
                return "Following"
            case .likers:
                return "Liked by"
            }
        }
    }
    
    let type: ListType
    
    init(type: ListType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        title = type.title
        
        configureViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func configureViewModel(){
//        DatabaseManager.shared.followers(for: "jjchauuuu") { followers in
//            DispatchQueue.main.async{
//                self.viewModel.append(ListUserTableViewCellViewModel(username: "jjchau", imageUrl: nil))
//            }
//        }
//
        
        switch type{
        case .likers(username: let usernames):
            usernames.forEach { username in
                viewModel.append(ListUserTableViewCellViewModel(username: username, imageUrl: nil))
            }
        case .folowers(user: let user):
            DatabaseManager.shared.followers(for: user.username) { [weak self] followers in
                DispatchQueue.main.async{
                    followers.forEach { follower in
                        self?.viewModel.append(ListUserTableViewCellViewModel(username: follower, imageUrl: nil))
                    }
                    self?.tableView.reloadData()
                }
            }
        case .following(user: let user):
            DatabaseManager.shared.following(for: user.username) {[weak self] followings in
                DispatchQueue.main.async{
                    followings.forEach { following in
                        self?.viewModel.append(ListUserTableViewCellViewModel(username: following, imageUrl: nil))
                    }
                    self?.tableView.reloadData()
                }
            }
        }
        
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ListUserTableViewCell.identifier, for: indexPath) as! ListUserTableViewCell
        cell.configure(with: viewModel[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let username = viewModel[indexPath.row].username
        DatabaseManager.shared.findUser(username: username) {[weak self] user in
            if let user = user {
                let vc = ProfileViewController(user: user)
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }
    
}
