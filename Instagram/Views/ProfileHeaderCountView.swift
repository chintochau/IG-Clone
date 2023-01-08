//
//  ProfileHeaderCountView.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-07.
//

import UIKit

protocol ProfileHeaderCountViewDelegate:AnyObject {
    func ProfileHeaderCountViewDidTapPostsButton(_ view: ProfileHeaderCountView)
    func ProfileHeaderCountViewDidTapFollowersButton(_ view: ProfileHeaderCountView)
    func ProfileHeaderCountViewDidTapFollowingButton(_ view: ProfileHeaderCountView)
}

class ProfileHeaderCountView: UIView {
    
    weak var delegate: ProfileHeaderCountViewDelegate?

    // count button
    
    private let postButton:UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.layer.cornerRadius = 4
        button.titleLabel?.textAlignment = .center
//        button.layer.borderWidth = 0.5
//        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
    }()
    private let followingButton:UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.layer.cornerRadius = 4
        button.titleLabel?.textAlignment = .center
//        button.layer.borderWidth = 0.5
//        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
    }()
    private let followerButton:UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.titleLabel?.numberOfLines = 2
        button.setTitle("-", for: .normal)
        button.layer.cornerRadius = 4
        button.titleLabel?.textAlignment = .center
//        button.layer.borderWidth = 0.5
//        button.layer.borderColor = UIColor.tertiaryLabel.cgColor
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(postButton)
        addSubview(followingButton)
        addSubview(followerButton)
        addActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonWidth:CGFloat = (width-10)/3
        postButton.frame = CGRect(x: 5, y: 0, width: buttonWidth, height: height)
        followerButton.frame = CGRect(x: postButton.right, y: 0, width: buttonWidth, height: height)
        followingButton.frame = CGRect(x: followerButton.right, y: 0, width: buttonWidth, height: height)
    }
    
    public func configure(with viewModel:ProfileHeaderCountViewModel){
        postButton.setTitle("\(viewModel.postsCount)\nPosts", for: .normal)
        followerButton.setTitle("\(viewModel.followerCount)\nFollowers", for: .normal)
        followingButton.setTitle("\(viewModel.followingCount)\nFollowing", for: .normal)
        
    }
    
    private func addActions(){
        postButton.addTarget(self, action: #selector(didTapPostButton), for: .touchUpInside)
        followerButton.addTarget(self, action: #selector(didTapFollowerButton), for: .touchUpInside)
        followingButton.addTarget(self, action: #selector(didTapFollowingButton), for: .touchUpInside)
    }
    
    @objc private func didTapPostButton(){
        delegate?.ProfileHeaderCountViewDidTapPostsButton(self)
    }
    
    @objc private func didTapFollowerButton(){
        delegate?.ProfileHeaderCountViewDidTapFollowersButton(self)
        
    }
    
    @objc private func didTapFollowingButton(){
        delegate?.ProfileHeaderCountViewDidTapFollowingButton(self)
        
    }

}
