//
//  PostLikesCollectionViewCell.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-03.
//

import UIKit

class PostLikesCollectionViewCell: UICollectionViewCell {
    
    private let likeLabel:UILabel = {
        let label = UILabel()
        label.textColor = .label
        return label
    }()
    
    static let identifier = "PostLikesCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(likeLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        likeLabel.text = "\(viewModel.likers.count) Likes"
    }
    
    
}
