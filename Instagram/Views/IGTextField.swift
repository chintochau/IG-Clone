//
//  IGTextField.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import UIKit

class IGTextField: UITextField {

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 50))
        leftViewMode = .always
        autocapitalizationType = .none
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.secondaryLabel.cgColor
        backgroundColor = .secondarySystemBackground
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
