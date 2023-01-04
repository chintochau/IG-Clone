//
//  PostActionCollectionViewCell.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-03.
//

import UIKit

protocol PostActionCollectionViewCellDelegate:AnyObject {
    func PostActionCollectionViewCelldidTapLikeButton(_ cell:PostActionCollectionViewCell, isLike:Bool)
    func PostActionCollectionViewCelldidTapCommentButton(_ cell:PostActionCollectionViewCell)
    func PostActionCollectionViewCelldidTapSendButton(_ cell:PostActionCollectionViewCell)
}

class PostActionCollectionViewCell: UICollectionViewCell {
    
    weak var delegate:PostActionCollectionViewCellDelegate?
    
    private var isLiked = false
    
    private let likeButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let image = UIImage(systemName: "heart", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
    }()
    private let commentButton: UIButton = {
        let button = UIButton()
        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        let image = UIImage(systemName: "message", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .label
        return button
    }()
    private let sendButton: UIButton = {
        let button = UIButton()
        button.tintColor = .label
        let config = UIImage.SymbolConfiguration(pointSize: 26, weight: .medium)
        let image = UIImage(systemName: "paperplane", withConfiguration: config)
        button.setImage(image, for: .normal)
        return button
    }()
    
    static let identifier = "PostActionCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(likeButton)
        contentView.addSubview(commentButton)
        contentView.addSubview(sendButton)
        likeButton.addTarget(self, action: #selector(didTapLikeButton), for: .touchUpInside)
        commentButton.addTarget(self, action: #selector(didTapCommentButton), for: .touchUpInside)
        sendButton.addTarget(self, action: #selector(didTapSendButton), for: .touchUpInside)
    }
    
    @objc private func didTapLikeButton (){
        isLiked = !isLiked
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let image = UIImage(systemName: isLiked ? "heart.fill":"heart", withConfiguration: config)
        likeButton.tintColor = isLiked ? .systemRed:.label
        likeButton.setImage(image, for: .normal)
        delegate?.PostActionCollectionViewCelldidTapLikeButton(self,isLike: isLiked)
    }
    @objc private func didTapCommentButton(){
        delegate?.PostActionCollectionViewCelldidTapCommentButton(self)
    }
    @objc private func didTapSendButton(){
        delegate?.PostActionCollectionViewCelldidTapSendButton(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let buttonSize = contentView.height
        likeButton.frame = CGRect(x: 10, y: 0, width: buttonSize, height: buttonSize)
        commentButton.frame = CGRect(x: likeButton.right, y: 0, width: buttonSize, height: buttonSize)
        sendButton.frame = CGRect(x: commentButton.right, y: 0, width: buttonSize, height: buttonSize)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let image = UIImage(systemName: "heart", withConfiguration: config)
        likeButton.setImage(image, for: .normal)
        likeButton.tintColor = .label
    }
    
    func configure(with viewModel: PostActionCollectionViewCellViewModel) {
        isLiked = viewModel.isLiked
        let config = UIImage.SymbolConfiguration(pointSize: 28, weight: .medium)
        let image = UIImage(systemName: isLiked ? "heart.fill":"heart", withConfiguration: config)
        likeButton.tintColor = isLiked ? .systemRed:.label
        likeButton.setImage(image, for: .normal)
    }
    
}
