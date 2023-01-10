//
//  CommentCollectionViewCell.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-09.
//

import UIKit

class CommentCollectionViewCell: UICollectionViewCell {
    
    
    private let label:UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .label
        return label
    }()
    
    static let identifier = "CommentCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentView.addSubview(label)
        
        
        
        // add constraints
//        NSLayoutConstraint.activate([
//            label.topAnchor.constraint(equalTo: contentView.topAnchor),
//            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
//        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        label.frame = CGRect(x: 20, y: 0, width: contentView.width-40, height: contentView.height)
    }
    
    public func configure(comment: Comment){
        label.text = "\(comment.username): \(comment.comment)"
    }
    
    
    
}
