//
//  PostLikesCollectionViewCell.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-03.
//

import UIKit

protocol PostLikesCollectionViewCellDelegate:AnyObject {
    func PostLikesCollectionViewCellDidTapLikeCount(_ cell:PostLikesCollectionViewCell,likers:[String])
}

class PostLikesCollectionViewCell: UICollectionViewCell {
    
    public weak var delegate:PostLikesCollectionViewCellDelegate?
    
    private var likers:[String] = []
    
    private let likeLabel:UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.isUserInteractionEnabled = true
        
        return label
    }()
    
    static let identifier = "PostLikesCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(likeLabel)
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLikeCount))
        tap.numberOfTapsRequired = 1
        likeLabel.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapLikeCount(){
        delegate?.PostLikesCollectionViewCellDidTapLikeCount(self,likers:likers)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        likeLabel.frame = CGRect(x: 20, y: 0, width: contentView.width-40, height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        likeLabel.text = nil
    }
    
    func configure(with viewModel: PostLikesCollectionViewCellViewModel) {
        likers = viewModel.likers
        likeLabel.text = viewModel.likers.count < 2 ? "\(viewModel.likers.count) Like" : "\(viewModel.likers.count) Likes"
    }
    
    
}
