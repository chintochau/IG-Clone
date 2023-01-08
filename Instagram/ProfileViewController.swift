//
//  ProfileViewController.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private let user:User
    
    private var posts:[Post]
    
    private var isCurrentUser:Bool {
        return user.username.lowercased() == UserDefaults.standard.string(forKey: "username")?.lowercased() ? true : false
    }
    
    
    private var collectionView: UICollectionView?

    private var headerViewModel: ProfileHeaderViewModel?
    
    private let activityIndicator:UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.startAnimating()
        indicator.hidesWhenStopped = true
        indicator.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        return indicator
    }()
    
    // MARK: - Init
    init(user: User) {
        self.user = user
        self.posts = []
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = user.username
        view.backgroundColor = .systemBackground
        configureNavBar()
        configureCollectionView()
        fetchUserData()
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.safeAreaLayoutGuide.layoutFrame
    }
    
    // MARK: - Fetch User Info
    private func fetchUserData(){
        let group  = DispatchGroup()
        group.enter()
        //Fetch Post
        DatabaseManager.shared.posts(for: user.username) { [weak self] result in
            defer {group.leave()}
            
            switch result{
            case .success(let resultPosts):
                self?.posts = resultPosts
            case .failure(_):
                return
            }
        }
        
        // Fetch Profile header
        var profilePictureUrl:URL?
        var buttonType:ProfileButtonType = .edit
        var following = 0
        var followers = 0
        var name:String?
        var bio:String?
        var postsCount = 0
        
        group.enter()
        // counts(3)
        DatabaseManager.shared.getUserCounts(username: user.username) { results in
            defer{group.leave()}
            following = results.following
            followers = results.followers
            postsCount = results.posts
        }
        
        group.enter()
        // bio, name
        DatabaseManager.shared.getUserInfo(username: user.username) { userinfo in
                defer{group.leave()}
            name = userinfo?.name
            bio = userinfo?.Bio
            
        }
        
        // profile picture url,
        group.enter()
        StorageManager.shared.profilePictureURL(for: user.username) { url in
            defer { group.leave() }
            profilePictureUrl = url
        }
        // if profile is not for current user, get follow state
        
        group.enter()
        DatabaseManager.shared.isFollowing(targetUsername: user.username) { isFollowing in
            defer { group.leave() }
            buttonType = .follow(isFollowing: isFollowing)
        }
        
        group.notify(queue: .main){
            self.headerViewModel = ProfileHeaderViewModel(
                username: name ?? name == "" ? self.user.username : name,
                profileUrl: profilePictureUrl,
                postCount: postsCount,
                followerCount: followers,
                followingCount: following,
                bio: bio,
                buttonType: self.isCurrentUser ? .edit : buttonType
            )
            
            self.collectionView?.reloadData()
            self.activityIndicator.stopAnimating()
        }
    }
    
    
    private func configureNavBar(){
        if isCurrentUser {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings))
        }else {
            
        }
    }
    
    
    @objc private func didTapSettings(){
        
        // navigate to settings page passing weak self
        let vc = SettingViewController()
        vc.title = "Create Account"
        /// pass in weak self to setting, and to signout page to prevent retain cycle
        vc.completion = { [weak self] in
            DispatchQueue.main.async {
//                let signInVC = SignInViewController()
                
                
                let vc = SignInViewController()
                let navVc = UINavigationController(rootViewController: vc)
                navVc.modalPresentationStyle = .fullScreen
                self?.present(navVc, animated: true)
                
//                signInVC.modalPresentationStyle = .fullScreen
//                self?.present(signInVC, animated: true)
            }
        }
        present(UINavigationController(rootViewController: vc),animated: true)
    }
    

  
}

// MARK: - Configure collectionView

extension ProfileViewController{
    
    private func configureCollectionView(){
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { index, _ -> NSCollectionLayoutSection? in
                
                let item = NSCollectionLayoutItem(
                    layoutSize:NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                      heightDimension: .fractionalHeight(1)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .fractionalWidth(1/3)),
                    subitem: item,
                    count: 3
                )
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [
                NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1),
                        heightDimension: .estimated(200)
                    ),
                    elementKind: UICollectionView.elementKindSectionHeader,
                    alignment: .top
                )
                
                ]
                
                return section
                
            })
        )
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)
        collectionView.register(ProfileHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier)
        
        view.addSubview(collectionView)
        
        self.collectionView = collectionView
        
    }
    
}

// MARK: - Delegate & DataSource
extension ProfileViewController: UICollectionViewDelegate,UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
        
        cell.configure(with: URL(string: posts[indexPath.row].postUrlString))
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let post = posts[indexPath.row]
        let vc = PostViewController(post: post)
        navigationController?.pushViewController(vc, animated: true)

    }
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ProfileHeaderCollectionReusableView.identifier, for: indexPath) as? ProfileHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        if let  headerViewModel = headerViewModel {
            headerView.configure(with: headerViewModel)
            headerView.countContainerView.delegate = self
            headerView.delegate = self
        }
        return headerView
    }
    
    
}

extension ProfileViewController:ProfileHeaderCountViewDelegate, ProfileHeaderCollectionReusableViewDelegate{
    
    func ProfileHeaderCountViewDidTapPostsButton(_ view: ProfileHeaderCountView) {
        collectionView?.scrollToItem(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }
    
    func ProfileHeaderCountViewDidTapFollowersButton(_ view: ProfileHeaderCountView) {
        let vc = ListViewController()
        vc.title = "Followers"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func ProfileHeaderCountViewDidTapFollowingButton(_ view: ProfileHeaderCountView) {
        let vc = ListViewController()
        vc.title = "Following"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func ProfileHeaderCollectionReusableViewDidTapEditProfile(_ view: ProfileHeaderCollectionReusableView) {
        let vc = EditProfileViewController()
        vc.completion = { [weak self] in
            self?.fetchUserData()
        }
        let navVc = UINavigationController(rootViewController: vc)
        navVc.modalPresentationStyle = .fullScreen
        present(navVc, animated: true)
    }
    
    func ProfileHeaderCollectionReusableViewDidTapFollow(_ view: ProfileHeaderCollectionReusableView) {
        DatabaseManager.shared.updateRelationship(state: .follow, for: user.username) { success in
            print(success)
//            self.headerViewModel?.buttonType = .follow(isFollowing: true)
            self.collectionView?.reloadData()
        }
    }

    func ProfileHeaderCollectionReusableViewDidTapUnfollow(_ view: ProfileHeaderCollectionReusableView) {
        DatabaseManager.shared.updateRelationship(state: .unfollow, for: user.username) { success in
            print(success)
//            self.headerViewModel?.buttonType = .follow(isFollowing: false)
            self.collectionView?.reloadData()
        }
        
    }

    
}
