//
//  LikeNotificationTableViewCell.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-06.
//

import UIKit


protocol LikeNotificationTableViewCellDelegate:AnyObject {
    func LikeNotificationTableViewCellDidTapPost(_ cell:LikeNotificationTableViewCell,
                                                 didTapPostwith viewModel: LikeNotificationCellViewModel)
}



class LikeNotificationTableViewCell: UITableViewCell {
    
    static let identifier = "LikeNotificationTableViewCell"
    
    private var viewModel:LikeNotificationCellViewModel?
    
    weak var delegate:LikeNotificationTableViewCellDelegate?
    
    private let profilePicture:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let postImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private let dateLabel:UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 14, weight: .light)
        return label
    }()
    
    
    private let label:UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .left
        label.font = .systemFont(ofSize: 18)
        return label
    }()
    
    // MARK: - Init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(profilePicture)
        contentView.addSubview(label)
        contentView.addSubview(postImageView)
        contentView.addSubview(dateLabel)
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapPost))
        gesture.numberOfTapsRequired = 1
        postImageView.addGestureRecognizer(gesture)
        selectionStyle = .none
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        profilePicture.frame = CGRect(x: 10, y: contentView.height/4, width: contentView.height/2, height: contentView.height/2)
        profilePicture.layer.cornerRadius = profilePicture.height/2
        postImageView.frame = CGRect(x: contentView.width - postImageView.width - 10,
                                     y: 2,
                                     width: contentView.height-4,
                                     height: contentView.height-4)
        let labelSize = label.sizeThatFits(CGSize(width: contentView.width-profilePicture.width-postImageView.width-30, height: contentView.height))
        
        
        dateLabel.sizeToFit()
        label.frame = CGRect(x: profilePicture.right+5, y: 0, width: labelSize.width, height: contentView.height)
        
        
        dateLabel.frame = CGRect(x: profilePicture.right+5, y: contentView.height - dateLabel.height, width: dateLabel.width, height: dateLabel.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        profilePicture.image = nil
        postImageView.image = nil
        dateLabel.text = nil
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func configure(with viewModel:LikeNotificationCellViewModel) {
        
        self.viewModel = viewModel
        profilePicture.sd_setImage(with: viewModel.profilePictureUrl)
        
        postImageView.sd_setImage(with: viewModel.postUrl)
        
        label.text = viewModel.username + " liked your Post."
        
        dateLabel.text = viewModel.dateString
        
    }
    
    @objc private func didTapPost(){
        guard let viewModel = self.viewModel else {return}
        delegate?.LikeNotificationTableViewCellDidTapPost(self, didTapPostwith: viewModel)
    }
}
