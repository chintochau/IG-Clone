//
//  PostCollectionViewCell.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-03.
//

import UIKit
import SDWebImage

protocol PostCollectionViewCellDelegate:AnyObject {
    func PostCollectionViewCellDidDoubleTapToLike(_ cell: PostCollectionViewCell, index:Int)
}

class PostCollectionViewCell: UICollectionViewCell {
    
    public weak var delegate:PostCollectionViewCellDelegate?
    private var index:Int = 0
    
    public let contentImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    public let heartImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "heart.fill",withConfiguration: UIImage.SymbolConfiguration(pointSize: 50))
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.alpha = 0
        
        return imageView
    }()
    
    static let identifier = "PostCollectionViewCell"
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(contentImageView)
        contentView.addSubview(heartImageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapToLike))
        tap.numberOfTapsRequired = 2
        contentImageView.addGestureRecognizer(tap)
    }
    
    @objc func didDoubleTapToLike(){
//        heartImageView.isHidden = false
//        UIView.animate(withDuration: 0.4, delay: 0) {
//            self.heartImageView.alpha = 1
//            self.heartImageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
//            self.heartImageView.center = self.contentImageView.center
//        }completion: { done in
//            if done {
//                UIView.animate(withDuration: 0.4, delay: 0) {
//                    self.heartImageView.alpha = 0
//                    self.heartImageView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
//                    self.heartImageView.center = self.contentImageView.center
//                }completion: { _ in
//                    self.heartImageView.isHidden = true
//                }
//            }
//        }
        delegate?.PostCollectionViewCellDidDoubleTapToLike(self,index:index)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentImageView.frame = contentView.bounds
        let size:CGFloat = 80
        heartImageView.frame = CGRect(x: 0, y: 0, width: size, height: size)
        heartImageView.center = contentImageView.center
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentImageView.image = nil
    }
    
    func configure(with viewModel: PostCollectionViewCellViewModel,index:Int) {
        contentImageView.sd_setImage(with: viewModel.postUrl)
        self.index = index
    }
    
}
