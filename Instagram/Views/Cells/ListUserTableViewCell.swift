//
//  ListUserTableViewCell.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-08.
//

import UIKit

class ListUserTableViewCell: UITableViewCell {
    static let identifier = "ListUserTableViewCell"
    
    private let profileImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .secondarySystemBackground
        return imageView
    }()
    
    private let usernameLabel:UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .label
        label.font = .systemFont(ofSize: 18)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profileImageView)
        contentView.addSubview(usernameLabel)
        accessoryType = .disclosureIndicator
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        profileImageView.image = nil
        usernameLabel.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.frame = CGRect(x: 10, y: contentView.height * (1-1/1.5)/2, width: contentView.height/1.5, height: contentView.height/1.5)
        profileImageView.layer.cornerRadius = profileImageView.height/2
        usernameLabel.sizeToFit()
        usernameLabel.frame = CGRect(x: profileImageView.right+10, y: (contentView.height-usernameLabel.height)/2, width: usernameLabel.width, height: usernameLabel.height)
    }
    
    
    public func configure(with viewModel: ListUserTableViewCellViewModel){
        StorageManager.shared.profilePictureURL(for: viewModel.username) { [weak self] url in
            self?.profileImageView.sd_setImage(with: url)
        }
        usernameLabel.text = viewModel.username
    }
    
}
