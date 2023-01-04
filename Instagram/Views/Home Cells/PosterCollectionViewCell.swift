//
//  PosterCollectionViewCell.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-03.
//
import SDWebImage
import UIKit

protocol PosterCollectionViewCellDelegate {
    func didTapMoreButton()
}

class PosterCollectionViewCell: UICollectionViewCell {
    
    var delegate:PosterCollectionViewCellDelegate?
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let usernameLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .medium)
        label.textColor = .label
        return label
    }()
    
    private let moreButton:UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    
    static let identifier = "PosterCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.addSubview(imageView)
        contentView.addSubview(usernameLabel)
        contentView.addSubview(moreButton)
        moreButton.addTarget(self, action: #selector(didTapMoreButton) , for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    @objc private func didTapMoreButton(){
        delegate?.didTapMoreButton()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 10, y: 3, width: contentView.height-6, height: contentView.height-6)
        imageView.layer.cornerRadius = imageView.height/2
        usernameLabel.sizeToFit()
        usernameLabel.frame = CGRect(x: imageView.right+10, y: 3, width: usernameLabel.width, height: contentView.height-6)
        moreButton.frame = CGRect(x: contentView.width - imageView.height, y: 3, width: imageView.height, height: imageView.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        usernameLabel.text = nil
    }
    
    func configure(with viewModel: PosterCollectionViewCellViewModel) {
        imageView.sd_setImage(with: viewModel.profilePictureUrl)
        usernameLabel.text = viewModel.username
    }
    
    
}
