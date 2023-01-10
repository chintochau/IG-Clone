//
//  PostDateTimeCollectionViewCell.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-03.
//

import UIKit

class PostDateTimeCollectionViewCell: UICollectionViewCell {
    
    
    private let dateLabel:UILabel = {
        let label = UILabel()
        label.textColor = .tertiaryLabel
        return label
    }()
    
    
    static let identifier = "PostDateTimeCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(dateLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        dateLabel.frame = CGRect(x: 20, y: 0, width: contentView.width-40, height: contentView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        dateLabel.text = nil
    }
    
    func configure(with viewModel: PostDateTimeCollectionViewCellViewModel) {
        let date = viewModel.date
        dateLabel.text = String.date(from: date)
    }
    
    
}
