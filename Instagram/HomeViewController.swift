//
//  ViewController.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import UIKit


class HomeViewController: UIViewController {
    
    
    private var collectionView:UICollectionView?
    
    private var viewModels = [[HomeFeedCellType]]()
    
    private var allPosts:[(post:Post,owner:String)] = []
    
    private var stories:[Story] = []
    private var users:[String] = []
    
    private var observer: NSObjectProtocol?
    
    private let activityIndicator:UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.startAnimating()
        indicator.hidesWhenStopped = true
        indicator.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        return indicator
    }()
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Instagram"
        view.backgroundColor = .systemBackground
        configureCollectionView()
        fetchPosts()
        
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
        
        observer = NotificationCenter.default.addObserver(forName: .didPostNotification, object: nil, queue: .main, using: { [weak self] _ in
            self?.viewModels.removeAll()
            self?.fetchPosts()
        })
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.safeAreaLayoutGuide.layoutFrame
    }
    
    // MARK: - Fetch Posts
    private func fetchPosts(){
        guard let username = UserDefaults.standard.string(forKey: "username") else {return}
        
        let userGroup = DispatchGroup()
        var allPosts:[(post:Post,owner:String)] = []
        userGroup.enter()
        DatabaseManager.shared.following(for: username) { usernames in
            
            defer {userGroup.leave()}
            
            
            let users = usernames + [username]
            self.users = users
            
            users.forEach { username in
                StorageManager.shared.profilePictureURL(for: username) { url in
                    self.stories.append(Story(username: username, image: url))
                }
            }
            
            
            
            for current in users {
                
                
                userGroup.enter()
                
                // loop for each user
                DatabaseManager.shared.posts(for: current) {result in
                    
                    DispatchQueue.main.async{
                        
                        switch result{
                        case .success(let posts):
                            defer {userGroup.leave()}
                            allPosts.append(contentsOf: posts.compactMap({ (post: $0, owner: current)
                            }))
                            
                        case .failure(_): break
                        }
                    }
                }
            }
        }
        
        userGroup.notify(queue: .main) {
            let group = DispatchGroup()
            self.allPosts = allPosts
            
            allPosts.forEach { post in
                group.enter()
                self.createViewModel(with: post.post, username: post.owner) { success in
                    do{
                        group.leave()
                    }
                }
            }
            
            group.notify(queue: .main){
                
                self.sortData()
                self.collectionView?.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    private func sortData(){
        
        allPosts.sort { first, second in
            first.post.date > second.post.date
        }
        
        viewModels.sort { first, second in
            var date1: Date?
            var date2: Date?
            
            first.forEach { type in
                switch type{
                case .timestamp(ViewModel: let vm):
                    date1 = vm.date
                default: break
                }
            }
            second.forEach { type in
                switch type{
                case .timestamp(ViewModel: let vm):
                    date2 = vm.date
                default: break
                }
            }
            if let date1 = date1, let date2 = date2 {
                return date1 > date2
            } else {
                return false
            }
        }
    }
    
    private func createViewModel(with post:Post, username:String, completion: @escaping (Bool) -> Void ){
        
        StorageManager.shared.profilePictureURL(for: username) { [weak self] profileURL in
            guard let postURL = URL(string: post.postUrlString), let profileURL = profileURL,
            let currentUser = UserDefaults.standard.string(forKey: "username") else {
                fatalError("failed to get url") }
            
            let postData:[HomeFeedCellType] = [
                .poster(ViewModel: PosterCollectionViewCellViewModel(username: username, profilePictureUrl: profileURL)),
                .post(ViewModel: PostCollectionViewCellViewModel(postUrl: postURL)),
                .actions(ViewModel: PostActionCollectionViewCellViewModel(isLiked: post.likers.contains(currentUser) )),
                .likeCount(ViewModel: PostLikesCollectionViewCellViewModel(likers: post.likers)),
                .caption(ViewModel: PostCaptionCollectionViewCellViewModel(username: username, caption: post.caption)),
                .timestamp(ViewModel: PostDateTimeCollectionViewCellViewModel(date: DateFormatter.formatter.date(from: post.postedDate) ?? Date()))
            ]
            
            
            self?.viewModels.append(postData)
            completion(true)
        }
        
        
    }
    
}

// MARK: - Configure Cell
extension HomeViewController:UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellType = viewModels[indexPath.section][indexPath.row]
        
        switch cellType {
        case .poster( let ViewModel):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCollectionViewCell.identifier, for: indexPath) as! PosterCollectionViewCell
            cell.configure(with: ViewModel,index: indexPath.section)
            cell.delegate = self
            return cell
            
        case .post( let ViewModel):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as! PostCollectionViewCell
            cell.configure(with: ViewModel, index:indexPath.section)
            cell.delegate = self
            return cell
            
        case .actions( let ViewModel):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostActionCollectionViewCell.identifier, for: indexPath) as! PostActionCollectionViewCell
            cell.configure(with: ViewModel, index: indexPath.section)
            cell.delegate = self
            return cell
            
        case .likeCount( let ViewModel):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostLikesCollectionViewCell.identifier, for: indexPath) as! PostLikesCollectionViewCell
            cell.configure(with: ViewModel)
            cell.delegate = self
            return cell
            
        case .caption( let ViewModel):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCaptionCollectionViewCell.identifier, for: indexPath) as! PostCaptionCollectionViewCell
            cell.configure(with: ViewModel)
            cell.delegate = self
            return cell
            
        case .timestamp( let ViewModel):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostDateTimeCollectionViewCell.identifier, for: indexPath) as! PostDateTimeCollectionViewCell
            cell.configure(with: ViewModel)
            return cell
            
        case .comment(comment: let comment):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CommentCollectionViewCell.identifier, for: indexPath) as! CommentCollectionViewCell
            return cell
            
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: StoryHeaderView.identifier, for: indexPath) as! StoryHeaderView
            
            view.configure(with: StoriesViewModel(stories: stories))
            
            return view
        default: break
        }
        return UICollectionReusableView()
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension HomeViewController {
    // MARK: - CollectionView
    private func configureCollectionView(){
        let sectionHeight:CGFloat = 340+view.width
        
        let collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout(
                sectionProvider: { index, _ -> NSCollectionLayoutSection? in
                    
                    // Cell for poster
                    let posterItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(60)
                        )
                    )
                    // Bigger cell for the post
                    let postItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .fractionalWidth(1)
                        )
                    )
                    // Actions cell
                    let actionItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(40)
                        )
                    )
                    // Like count cell
                    let likeCountItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(20)
                        )
                    )
                    // Captions cell
                    let captionItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(60)
                        )
                    )
                    // Timestamp cell
                    let timestampItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(40)
                        )
                    )
                    // Comment cell
                    let commentItem = NSCollectionLayoutItem(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(40)
                        )
                    )
                    
                    // Group
                    let group = NSCollectionLayoutGroup.vertical(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1),
                            heightDimension: .absolute(sectionHeight)
                            
                        ),
                        subitems: [
                            posterItem,
                            postItem,
                            actionItem,
                            likeCountItem,
                            captionItem,
                            timestampItem,
                            commentItem
                        ]
                    )
                    
                    // Section
                    let section =  NSCollectionLayoutSection(group: group)
                    if index == 0 {
                        
                        section.boundarySupplementaryItems = [
                        NSCollectionLayoutBoundarySupplementaryItem(
                            layoutSize: NSCollectionLayoutSize(
                                widthDimension: .fractionalWidth(1),
                                heightDimension: .estimated(100)
                            ),
                            elementKind: UICollectionView.elementKindSectionHeader,
                            alignment: .top
                        )
                        
                        ]
                    }
                    section.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 0, bottom: 3, trailing: 0)
                    
                    return section
                })
        )
        
        collectionView.register(PostCollectionViewCell.self, forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
        collectionView.register(PosterCollectionViewCell.self, forCellWithReuseIdentifier: PosterCollectionViewCell.identifier)
        collectionView.register(PostLikesCollectionViewCell.self, forCellWithReuseIdentifier: PostLikesCollectionViewCell.identifier)
        collectionView.register(PostActionCollectionViewCell.self, forCellWithReuseIdentifier: PostActionCollectionViewCell.identifier)
        collectionView.register(PostDateTimeCollectionViewCell.self, forCellWithReuseIdentifier: PostDateTimeCollectionViewCell.identifier)
        collectionView.register(PostCaptionCollectionViewCell.self, forCellWithReuseIdentifier: PostCaptionCollectionViewCell.identifier)
        collectionView.register(StoryHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: StoryHeaderView.identifier)
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView = collectionView
    }
}

// MARK: - Actions
extension HomeViewController:PosterCollectionViewCellDelegate,PostActionCollectionViewCellDelegate,PostCollectionViewCellDelegate,PostLikesCollectionViewCellDelegate, PostCaptionCollectionViewCellDelegate {
    
    func PostCaptionCollectionViewCellDidTapCaption(_ cell: PostCaptionCollectionViewCell) {
        print("caption")
    }
    
    func PostLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell,likers:[String]) {
        // present like people
        let vc = ListViewController(type: .likers(username: likers))
        vc.title = "Liked by"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func PostCollectionViewCellDidDoubleTapToLike(_ cell: PostCollectionViewCell,index:Int) {
        let model = allPosts[index]
        
        DatabaseManager.shared.updateLike(state: .like, postID: model.post.id, owner: model.owner) { success in
            guard let currentUser = UserDefaults.standard.string(forKey: "username") else {return}
            if success{
                var likers:[String] = []
                switch self.viewModels[index][3]{
                case .likeCount(let model):
                    likers = model.likers
                    likers.appendIfNotContains(currentUser)
                default: print("should not execute")
                }
                
                self.viewModels[index][2] = .actions(ViewModel: PostActionCollectionViewCellViewModel(isLiked: likers.contains(currentUser)))
                self.viewModels[index][3] = .likeCount(ViewModel: PostLikesCollectionViewCellViewModel(likers: likers ))
                cell.heartImageView.isHidden = false
                
                let likeCell = self.collectionView?.cellForItem(at: IndexPath(row: 2, section: index)) as! PostActionCollectionViewCell
                let likeButton = likeCell.likeButton
                likeButton.tintColor = .systemRed
                
                likeButton.setImage(UIImage(systemName:"heart.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .medium)), for: .normal)
                
                
                
                UIView.animate(withDuration: 0.2, delay: 0) {
                    cell.heartImageView.alpha = 1
                    cell.heartImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                    cell.heartImageView.center = cell.contentImageView.center
                    likeButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                    
                }completion: { done in
                    if done {
                        UIView.animate(withDuration: 0.2, delay: 0) {
                            cell.heartImageView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
                            cell.heartImageView.center = cell.contentImageView.center
                            likeButton.transform = CGAffineTransform(scaleX: 1, y: 1)
                        }completion: { _ in
                            
                            UIView.animate(withDuration: 0.3, delay: 0) {
                                cell.heartImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
                                cell.heartImageView.center = cell.contentImageView.center
                                
                            }completion: { _ in
                                
                                self.collectionView?.reloadData()
                                cell.heartImageView.alpha = 0
                                cell.heartImageView.isHidden = true
                            }
                        }
                    }
                }
            }
        }
        
        
        // add noti for user implement not done
//        let username = UserDefaults.standard.string(forKey: "username")
//        let id = NotificationManager.newIdentifier()
//        let model = IGNotification(identifier: id,
//                                   notificationType: 1,
//                                   profilePictureUrlString: "https://www.planetware.com/wpimages/2020/01/iceland-in-pictures-beautiful-places-to-photograph-jokulsarlon-glacier-lagoon.jpg",
//                                   username: "ElonMusk11",
//                                   dateString: String.date(from: Date()) ?? "Now",
//                                   isFollowing: nil, postId: "123",
//                                   PostUrl: "https://www.planetware.com/wpimages/2020/01/iceland-in-pictures-beautiful-places-to-photograph-jokulsarlon-glacier-lagoon.jpg")
//        NotificationManager.shared.create(notification: model, for: username ?? "jjchau")
        
        
    }
    
    func PosterCollectionViewCelldidTapUsernameButton(_ cell: PosterCollectionViewCell, username: String) {
        let vc = ProfileViewController(user: User(username: username, email: ""))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func PosterCollectionViewCelldidTapMoreButton(_ cell: PosterCollectionViewCell, index:Int) {
        
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Share Post", style: .default,handler: { [weak self] _ in
            guard let postURL = URL(string: self?.allPosts[index].post.postUrlString ?? "") else {return}
            let vc = UIActivityViewController(activityItems: ["Check out this cool post!", postURL],
                                              applicationActivities: [])
            self?.present(vc,animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Report Post", style: .destructive))
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet,animated: true)
    }
    
    func PostActionCollectionViewCelldidTapLikeButton(_ cell: PostActionCollectionViewCell, toLike: Bool, index:Int) {
        let model = allPosts[index]
        
        print("3\(toLike)")
        DatabaseManager.shared.updateLike(state: .like, postID: model.post.id, owner: model.owner) { success in
            guard let currentUser = UserDefaults.standard.string(forKey: "username") else {return}
            if success{
                
                var likers:[String] = []
                
                switch self.viewModels[index][3]{
                case .likeCount(let model):
                    likers = model.likers
                    switch toLike {
                    case true: // to like
                        
                        print("4\(toLike)")
                        likers.appendIfNotContains(currentUser)
                        print(likers)
                    case false: // to unlike
                        guard let currentUserIndex = likers.firstIndex(of: currentUser) else {return}
                        
                        print("5\(toLike)")
                        likers.remove(at: currentUserIndex)
                        print(likers)
                    }
                    
                default: print("never")
                    
                }
                self.viewModels[index][2] = .actions(ViewModel: PostActionCollectionViewCellViewModel(isLiked: likers.contains(currentUser)))
                self.viewModels[index][3] = .likeCount(ViewModel: PostLikesCollectionViewCellViewModel(likers: likers ))
                self.collectionView?.reloadData()
                
                
                
            }
        }
        
        
    }
    
    func PostActionCollectionViewCelldidTapSendButton(_ cell: PostActionCollectionViewCell, index:Int) {
        guard let postURL = URL(string: allPosts[index].post.postUrlString) else {return}
        
        let vc = UIActivityViewController(activityItems: ["Check out this cool post!", postURL],
                                          applicationActivities: [])
        present(vc,animated: true)
    }
    func PostActionCollectionViewCelldidTapCommentButton(_ cell: PostActionCollectionViewCell, index:Int) {
        let vc = PostViewController(post: allPosts[index].post,username:allPosts[index].owner)
        vc.title = "Post"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
