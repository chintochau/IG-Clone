//
//  CommentBarView.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-09.
//

import UIKit

protocol CommentBarViewDelegate:AnyObject {
    func CommentBarViewDidTapSend(_ commentBarView:CommentBarView, with text:String)
}

class CommentBarView: UIView, UITextFieldDelegate {
    
    static let identifier = "CommentBarView"

    weak var delegate: CommentBarViewDelegate?
    
    private let button:UIButton = {
        let button = UIButton()
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.link, for: .normal)
        
        return button
    }()
    
    private let field:IGTextField = {
        let field = IGTextField()
        field.placeholder = "Comment"
        field.backgroundColor = .systemBackground
        field.autocorrectionType = .no
        field.spellCheckingType = .no
        return field
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(button)
        addSubview(field)
        field.delegate = self
        button.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        backgroundColor = .systemBackground
    }
    
    @objc private func didTapSend(){
        guard let text = field.text, !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
        }
        field.text = nil
        field.resignFirstResponder()
        delegate?.CommentBarViewDidTapSend(self, with: text)
                
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let size = height
        button.frame = CGRect(x: width-size, y: 0, width: size, height: size)
        field.frame = CGRect(x: 3, y: 3, width: width-button.width-6, height: height-6)
        field.layer.cornerRadius = field.height/2
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        didTapSend()
        return true
    }
}
