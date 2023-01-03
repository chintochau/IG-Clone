//
//  SIgnInHeaderView.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import UIKit

class SignInHeaderView: UIView {
    
    
    var gradientLayer:CAGradientLayer?
    
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "text_logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        createGradient()
        addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func createGradient(){
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.cgColor,UIColor.systemPink.cgColor]
        layer.addSublayer(gradientLayer)
        self.gradientLayer = gradientLayer
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer?.frame = layer.bounds
        imageView.frame = CGRect(x: 20, y: height/3, width: width-40, height: height/3)
    }
    

}
