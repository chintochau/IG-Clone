//
//  ProfileHeaderCollectionReusableView.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-07.
//

import UIKit

protocol ProfileHeaderCollectionReusableViewDelegate:AnyObject {
    func ProfileHeaderCollectionReusableViewDidTapEditProfile(_ view:ProfileHeaderCollectionReusableView)
    func ProfileHeaderCollectionReusableViewDidTapFollow(_ view:ProfileHeaderCollectionReusableView)
    func ProfileHeaderCollectionReusableViewDidTapUnfollow(_ view:ProfileHeaderCollectionReusableView)
}

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    static let identifier = "ProfileHeaderCollectionReusableViewCell"
    
    weak var delegate: ProfileHeaderCollectionReusableViewDelegate?
    
    private var vm:ProfileHeaderViewModel?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private let nameLabel:UILabel = {
        let label = UILabel()
        label.textColor = .label
        return label
    }()
    
    private let bioLabel:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .label
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    private let followEditButton:UIButton = {
        let button = UIButton()
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 8
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Follow", for: .normal)
        return button
    }()
    
    public let countContainerView = ProfileHeaderCountView()

 
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(countContainerView)
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(bioLabel)
        addSubview(followEditButton)
        addAction()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 5, y: 5, width: width/4, height: width/4)
        imageView.layer.cornerRadius = imageView.height/2
        countContainerView.frame = CGRect(x: imageView.right, y: imageView.height/4+5, width: width-imageView.width, height: imageView.height/2)
        
        
        /// Layout does not update when data fetched, change from lifecycle layoutsubviews to end of configure
        
//        nameLabel.sizeToFit()
//        nameLabel.frame = CGRect(x: 5, y: imageView.bottom+5, width: width-10, height: nameLabel.height)
//        bioLabel.frame = CGRect(x: 5, y: nameLabel.bottom+5, width: width-10, height: height-imageView.height-nameLabel.height-10)
//        bioLabel.sizeToFit()
//        followEditButton.frame = CGRect(x: 15, y: bioLabel.bottom+5, width: width - 30, height: 35)
//

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bioLabel.text = nil
        imageView.image = nil
        nameLabel.text = nil
    }
    
    public func configure(with viewModel:ProfileHeaderViewModel) {
        
        //container
        let containerViewModel = ProfileHeaderCountViewModel(
            followerCount: viewModel.followerCount,
            followingCount: viewModel.followingCount,
            postsCount: viewModel.postCount)
        countContainerView.configure(with: containerViewModel)
        
        // self
        imageView.sd_setImage(with: viewModel.profileUrl)
        nameLabel.text = viewModel.username
        bioLabel.text = viewModel.bio ?? ""
        switch viewModel.buttonType {
        case .follow(let following):
            self.followEditButton.setTitle(following ? "Following" : "Follow", for: .normal)
            self.followEditButton.setTitleColor(following ? UIColor.label : UIColor.white, for: .normal)
            self.followEditButton.backgroundColor = following ? .tertiarySystemBackground : .systemBlue
        case .edit:
            self.followEditButton.setTitle("Edit Profile", for: .normal)
            self.followEditButton.backgroundColor = .tertiarySystemBackground
            self.followEditButton.setTitleColor(.label, for: .normal)
        }
        
        self.vm = viewModel
        
        
        nameLabel.sizeToFit()
        nameLabel.frame = CGRect(x: 5, y: imageView.bottom+5, width: width-10, height: nameLabel.height)
        bioLabel.frame = CGRect(x: 5, y: nameLabel.bottom+5, width: width-10, height: height-imageView.height-nameLabel.height-10)
        bioLabel.sizeToFit()
        followEditButton.frame = CGRect(x: 15, y: bioLabel.bottom+5, width: width - 30, height: 35)
        
        
        frame = CGRect(x: 0, y: 0, width: width, height: nameLabel.height+bioLabel.height+imageView.height+followEditButton.height+30)
        
    }
    
    
    private func addAction(){
        followEditButton.addTarget(self, action: #selector(didTapFollowEditButton), for: .touchUpInside)
    }
    
    @objc private func didTapFollowEditButton(){
        guard let buttonType = vm?.buttonType else {return}
        switch buttonType {
        case .follow(let isFollowing):
            if isFollowing {
                delegate?.ProfileHeaderCollectionReusableViewDidTapUnfollow(self)
            }else {
                delegate?.ProfileHeaderCollectionReusableViewDidTapFollow(self)
            }
        case .edit:
            delegate?.ProfileHeaderCollectionReusableViewDidTapEditProfile(self)
        }
        
    }
    
}

