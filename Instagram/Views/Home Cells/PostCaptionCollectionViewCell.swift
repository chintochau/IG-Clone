//
//  PostCaptionCollectionViewCell.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-03.
//

import UIKit

protocol PostCaptionCollectionViewCellDelegate:AnyObject {
    func PostCaptionCollectionViewCellDidTapCaption(_ cell:PostCaptionCollectionViewCell)
}

class PostCaptionCollectionViewCell: UICollectionViewCell {
    
    var delegate:PostCaptionCollectionViewCellDelegate?
    
    private let captionLabel:UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        return label
    }()
    
    static let identifier = "PostCaptionCollectionViewCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(captionLabel)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapCaption))
        tap.numberOfTapsRequired = 1
        captionLabel.addGestureRecognizer(tap)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapCaption(){
        delegate?.PostCaptionCollectionViewCellDidTapCaption(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = captionLabel.sizeThatFits(contentView.bounds.size)
        captionLabel.frame = CGRect(x: 20, y: 0, width: contentView.width-20, height: size.height)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        captionLabel.text = nil
    }
    
    func configure(with viewModel: PostCaptionCollectionViewCellViewModel) {
        captionLabel.text = "\(viewModel.username) \(viewModel.caption ?? "")"
    }
    
    
    
}
