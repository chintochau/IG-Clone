//
//  PhotoCollectionViewCell.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-04.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    
    static let identifier = "PhotoCollectionViewCell"
    
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    func configure(with image:UIImage?) {
        imageView.image = image
    }
    
    
    
}
