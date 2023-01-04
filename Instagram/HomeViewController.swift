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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Instagram"
        view.backgroundColor = .systemBackground
        configureCollectionView()
        fetchPosts()
        
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView?.frame = view.safeAreaLayoutGuide.layoutFrame
    }
    
    private func fetchPosts(){
        // mock data
        let postData:[HomeFeedCellType] = [
            .poster(ViewModel: PosterCollectionViewCellViewModel(username: "jjchau", profilePictureUrl: URL(string: "https://loremflickr.com/320/240")!)),
            .post(ViewModel: PostCollectionViewCellViewModel(postUrl: URL(string: "https://loremflickr.com/320/240")!)),
            .actions(ViewModel: PostActionCollectionViewCellViewModel(isLiked: true)),
            .likeCount(ViewModel: PostLikesCollectionViewCellViewModel(likers: ["jjchauu","Chan","Cheung"])),
            .caption(ViewModel: PostCaptionCollectionViewCellViewModel(username: "jjchauuu", caption: "Happy New Year!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!9999")),
            .timestamp(ViewModel: PostDateTimeCollectionViewCellViewModel(date: Date()))
        ]
        
        viewModels.append(postData)
        
    }
    
}

// MARK: - Configure Cell
extension HomeViewController:UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellType = viewModels[indexPath.section][indexPath.row]
        
        switch cellType {
        case .poster( let ViewModel):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCollectionViewCell.identifier, for: indexPath) as! PosterCollectionViewCell
            cell.configure(with: ViewModel)
            cell.delegate = self
            return cell
            
        case .post( let ViewModel):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as! PostCollectionViewCell
            cell.configure(with: ViewModel)
            cell.delegate = self
            return cell
            
        case .actions( let ViewModel):
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostActionCollectionViewCell.identifier, for: indexPath) as! PostActionCollectionViewCell
            cell.configure(with: ViewModel)
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
    // MARK: - Create and configure CollectionView
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
        
        
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.collectionView = collectionView
    }
}

extension HomeViewController:PosterCollectionViewCellDelegate,PostActionCollectionViewCellDelegate,PostCollectionViewCellDelegate,PostLikesCollectionViewCellDelegate, PostCaptionCollectionViewCellDelegate {
    
    func PostCaptionCollectionViewCellDidTapCaption(_ cell: PostCaptionCollectionViewCell) {
        print("caption")
    }
    
    func PostLikesCollectionViewCellDidTapLikeCount(_ cell: PostLikesCollectionViewCell) {
        // present like people
        let vc = ListViewController()
        vc.title = "Liked by"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func PostCollectionViewCellDidLike(_ cell: PostCollectionViewCell) {
        print("double tap to like")
    }
    
    func PosterCollectionViewCelldidTapUsernameButton(_ cell: PosterCollectionViewCell) {
        print("username")
        
        let vc = ProfileViewController(user: User(username: "jjchau", email: "jj@jj.com"))
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func PosterCollectionViewCelldidTapMoreButton(_ cell: PosterCollectionViewCell) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Report Post", style: .destructive))
        actionSheet.addAction(UIAlertAction(title: "Share Post", style: .default))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet,animated: true)
    }
    
    func PostActionCollectionViewCelldidTapLikeButton(_ cell: PostActionCollectionViewCell, isLike: Bool) {
        //call db to update like state
    }
    
    func PostActionCollectionViewCelldidTapSendButton(_ cell: PostActionCollectionViewCell) {
        let vc = UIActivityViewController(activityItems: ["Sharing from IG"], applicationActivities: [])
        present(vc,animated: true)
    }
    func PostActionCollectionViewCelldidTapCommentButton(_ cell: PostActionCollectionViewCell) {
        let vc = PostViewController()
        vc.title = "Post"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
    
}
