//
//  NotificationTableViewCell.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-06.
//

import UIKit

protocol FollowNotificationTableViewCellDelegate:AnyObject {
    func FollowNotificationTableViewCellDidTapFollowButton(_ cell:FollowNotificationTableViewCell, didTapButton isFollowing:Bool, with viewModel:FollowNotificationCellViewModel)
}

class FollowNotificationTableViewCell: UITableViewCell {
    
    static let identifier = "FollowNotificationTableViewCell"
    
    private var isFollowing:Bool = false
    
    private var viewModel:FollowNotificationCellViewModel?
    
    weak var delegate:FollowNotificationTableViewCellDelegate?
    
    private let profilePicture:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    
    private let label:UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    private let dateLabel:UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    private let followButton = IGFollowButton()
    
    
// MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profilePicture)
        contentView.addSubview(label)
        contentView.addSubview(followButton)
        contentView.addSubview(dateLabel)
        followButton.addTarget(self, action: #selector(didTapFollowButton), for: .touchUpInside)
        selectionStyle = .none
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profilePicture.frame = CGRect(x: 10, y: contentView.height/4, width: contentView.height/2, height: contentView.height/2)
        profilePicture.layer.cornerRadius = profilePicture.height/2
        
        
        followButton.sizeToFit()
        let buttonWidth: CGFloat = max(followButton.width, 75)
        followButton.frame = CGRect(x: contentView.width - buttonWidth - 24,
                                    y: (contentView.height - followButton.height)/2,
                                    width: buttonWidth+14,
                                    height: followButton.height)
        
        let labelSize = label.sizeThatFits(CGSize(width: contentView.width-profilePicture.width-followButton.width-25, height: contentView.height))
        
        dateLabel.sizeToFit()
        label.frame = CGRect(x: profilePicture.right+5, y: 0, width: labelSize.width, height: contentView.height-dateLabel.height)
        
        
        dateLabel.frame = CGRect(x: profilePicture.right+5, y: contentView.height - dateLabel.height, width: dateLabel.width, height: dateLabel.height)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        profilePicture.image = nil
        dateLabel.text = nil
        followButton.setTitle(nil, for: .normal)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func configure(with viewModel:FollowNotificationCellViewModel) {
        self.viewModel = viewModel
        profilePicture.sd_setImage(with: viewModel.profilePictureUrl)
        label.text = viewModel.username + " started following you."
        dateLabel.text = viewModel.dateString

        followButton.configure(for: viewModel.isCurrentUserFollowing ? .unfollow: .follow)
    }

    
    @objc private func didTapFollowButton(){
        guard let viewModel = viewModel else {return}
        delegate?.FollowNotificationTableViewCellDidTapFollowButton(self, didTapButton: !isFollowing, with: viewModel)
        isFollowing = !isFollowing
        followButton.configure(for: isFollowing ? .unfollow: .follow)
        
    }
    
}
