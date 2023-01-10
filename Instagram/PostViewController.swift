//
//  PostViewController.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import UIKit

class PostViewController: UIViewController {
    
    private var post:Post,username:String
    
    private var collectionView:UICollectionView?
    
    private var viewModel = [HomeFeedCellType]()
    
    private var observer: NSObjectProtocol?
    private var hideObserver: NSObjectProtocol?
    
    private let activityIndicator:UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.startAnimating()
        indicator.hidesWhenStopped = true
        indicator.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        return indicator
    }()
    
    private let commentBar:CommentBarView = {
        let commentBar = CommentBarView()
        
        return commentBar
    }()
    
    // MARK: - Init
    
    init(post:Post,username:String) {
        self.post = post
        self.username = username
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Post"
        view.backgroundColor = .systemBackground
        configureCollectionView()
        
        fetchPost()
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
        view.addSubview(commentBar)
        commentBar.delegate = self
        observeKeyboardChange()
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionView?.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height-50-view.safeAreaInsets.bottom)
        
        
        commentBar.frame = CGRect(x: 0, y: view.height-view.safeAreaInsets.bottom-50, width: view.width, height: 50)
    }
    
    private func observeKeyboardChange(){
        observer = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { notification in
            guard let userInfo = notification.userInfo,
                  let height = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height else {return}
            
            
            //            self.commentBar.frame = CGRect(x: 0, y: self.view.height-50-height, width: self.view.width, height: 50)
            self.view.frame.origin.y -= height
        }
        
        hideObserver = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { notification in
            
            //            self.commentBar.frame = CGRect(x: 0, y: self.view.height-self.view.safeAreaInsets.bottom-50, width: self.view.width, height: 50)
            self.view.frame.origin.y = 0
        }
    }
    
    // MARK: - Fetch Posts
    private func fetchPost(){
        guard username != "" else {return}
        
        // update username to a particular username
        DatabaseManager.shared.getPost(with: post.id, from: username) { post in
            guard let post = post else {return}
            
            self.createViewModel(with: post, username: self.username) { success in
                self.collectionView?.reloadData()
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    
    private func createViewModel(with post:Post, username:String, completion: @escaping (Bool) -> Void ){
        
        StorageManager.shared.profilePictureURL(for: username) { [weak self] profileURL in
            guard let postURL = URL(string: post.postUrlString), let profileURL = profileURL else {
                fatalError("faile to get url") }
            
            let postData:[HomeFeedCellType] = [
                .poster(ViewModel: PosterCollectionViewCellViewModel(username: username, profilePictureUrl: profileURL)),
                .post(ViewModel: PostCollectionViewCellViewModel(postUrl: postURL)),
                .actions(ViewModel: PostActionCollectionViewCellViewModel(isLiked: false)),
                .likeCount(ViewModel: PostLikesCollectionViewCellViewModel(likers: post.likers)),
                .caption(ViewModel: PostCaptionCollectionViewCellViewModel(username: username, caption: post.caption)),
                .timestamp(ViewModel: PostDateTimeCollectionViewCellViewModel(date: DateFormatter.formatter.date(from: post.postedDate) ?? Date()))
            ]
            self?.viewModel = postData
            completion(true)
        }
        
        
    }
    
}

// MARK: - Configure Cell
extension PostViewController:UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellType = viewModel[indexPath.row]
        
        switch cellType {
        case .poster( let ViewModel):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCollectionViewCell.identifier, for: indexPath) as! PosterCollectionViewCell
            cell.configure(with: ViewModel,index: indexPath.section)
            cell.delegate = self
            return cell
            
        case .post( let ViewModel):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as! PostCollectionViewCell
            cell.configure(with: ViewModel)
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
            
        }
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension PostViewController {
    // MARK: - CollectionView
    private func configureCollectionView(){
        let sectionHeight:CGFloat = 300+view.width
        
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
                            timestampItem
                        ]
                    )
                    
                    // Section
                    let section =  NSCollectionLayoutSection(group: group)
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
        collectionView.register(CommentCollectionViewCell.self, forCellWithReuseIdentifier: CommentCollectionViewCell.identifier)
        collectionView.register(CommentBarView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter  , withReuseIdentifier: CommentBarView.identifier)
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.keyboardDismissMode = .interactive
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView = collectionView
    }
}

// MARK: - Actions
extension PostViewController:PosterCollectionViewCellDelegate,PostActionCollectionViewCellDelegate,PostCollectionViewCellDelegate,PostLikesCollectionViewCellDelegate, PostCaptionCollectionViewCellDelegate,CommentBarViewDelegate {
    
    func CommentBarViewDidTapSend(_ commentBarView: CommentBarView, with text: String) {
        
        guard let currentUsername = UserDefaults.standard.string(forKey: "username") else {return}
            DatabaseManager.shared.setComment(postID: post.id, owner: username, comment: Comment(username: currentUsername, comment: text, dateSDtring: String.date(from: Date()) ?? "Now" )) { _ in
                
            }
        
    }
    
    
    func PostCaptionCollectionViewCellDidTapCaption(_ cell: PostCaptionCollectionViewCell) {
        print("caption")
    }
    
    func PostLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell) {
        // present like people
        let vc = ListViewController(type: .likers(username: []))
        vc.title = "Liked by"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func PostCollectionViewCellDidLike(_ cell: PostCollectionViewCell) {
        
        // add dummy noti for current user
        let username = UserDefaults.standard.string(forKey: "username")
        let id = NotificationManager.newIdentifier()
        let model = IGNotification(identifier: id,
                                   notificationType: 1,
                                   profilePictureUrlString: "https://www.planetware.com/wpimages/2020/01/iceland-in-pictures-beautiful-places-to-photograph-jokulsarlon-glacier-lagoon.jpg",
                                   username: "ElonMusk11",
                                   dateString: String.date(from: Date()) ?? "Now",
                                   isFollowing: nil, postId: "123",
                                   PostUrl: "https://www.planetware.com/wpimages/2020/01/iceland-in-pictures-beautiful-places-to-photograph-jokulsarlon-glacier-lagoon.jpg")
        NotificationManager.shared.create(notification: model, for: username ?? "jjchau")
        
        
    }
    
    func PosterCollectionViewCelldidTapUsernameButton(_ cell: PosterCollectionViewCell, username: String) {
        let vc = ProfileViewController(user: User(username: username, email: ""))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func PosterCollectionViewCelldidTapMoreButton(_ cell: PosterCollectionViewCell, index:Int) {
        
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Share Post", style: .default,handler: { [weak self] _ in
            guard let postURL = URL(string: self?.post.postUrlString ?? "") else {return}
            let vc = UIActivityViewController(activityItems: ["Check out this cool post!", postURL],
                                              applicationActivities: [])
            self?.present(vc,animated: true)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Report Post", style: .destructive))
        
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet,animated: true)
    }
    
    func PostActionCollectionViewCelldidTapLikeButton(_ cell: PostActionCollectionViewCell, isLike: Bool, index:Int) {
        //call db to update like state
        
    }
    
    func PostActionCollectionViewCelldidTapSendButton(_ cell: PostActionCollectionViewCell, index:Int) {
        guard let postURL = URL(string: post.postUrlString) else {return}
        
        let vc = UIActivityViewController(activityItems: ["Check out this cool post!", postURL],
                                          applicationActivities: [])
        present(vc,animated: true)
    }
    
    
    func PostActionCollectionViewCelldidTapCommentButton(_ cell: PostActionCollectionViewCell, index:Int) {
        let vc = PostViewController(post: post,username: username)
        vc.title = "Post"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
