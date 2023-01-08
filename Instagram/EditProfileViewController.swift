//
//  EditProfileViewController.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-07.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    
    public var completion: (() -> Void)?
    
    
    private let nameField: IGTextField = {
        let field = IGTextField()
        field.placeholder = "Name..."
        return field
    }()
    
    private let bioTextView:UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        textView.backgroundColor = .secondarySystemBackground
        textView.font = .systemFont(ofSize: 18)
        return textView
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Edit Profile"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
        
        view.addSubview(nameField)
        view.addSubview(bioTextView)
        
        guard let username = UserDefaults.standard.string(forKey: "username") else {return}
                DatabaseManager.shared.getUserInfo(username: username) { userInfo in
                    self.bioTextView.text = userInfo?.Bio
                    self.nameField.text = userInfo?.name
                    
                }
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        nameField.frame = CGRect(x: 5, y: view.safeAreaInsets.top+5, width: view.width-10, height: 50)
        bioTextView.frame = CGRect(x: 5, y: nameField.bottom+5, width: view.width-10, height: 500)
    }
    
    
    
    
    @objc private func didTapClose (){
        dismiss(animated: true)
    }
    @objc private func didTapSave (){
        // perform Save
        let newInfo = UserInfo(name: nameField.text ?? "", Bio: bioTextView.text)
        DatabaseManager.shared.setUserInfo(userinfo: newInfo) {[weak self] success in
            DispatchQueue.main.async{
                if success {
                    self?.dismiss(animated: true)
                    self?.completion?()
                }else {
                    
                }
            }
        }
    }
    


}
