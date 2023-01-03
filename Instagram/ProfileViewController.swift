//
//  ProfileViewController.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import UIKit

class ProfileViewController: UIViewController {
    
    private let user:User
    
    private var isCurrentUser:Bool {
        return user.username.lowercased() == UserDefaults.standard.string(forKey: "username")?.lowercased() ? true : false
    }

    // MARK: - Init
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = user.username
        view.backgroundColor = .systemBackground
        configure()
        
    }
    
    
    private func configure(){
        if isCurrentUser {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings))
        }else {
            
        }
    }
    
    @objc private func didTapSettings(){
        
        // navigate to settings page passing weak self
        let vc = SettingViewController()
        vc.title = "Create Account"
        /// pass in weak self to setting, and to signout page to prevent retain cycle
        vc.completion = { [weak self] in
            DispatchQueue.main.async {
                let signInVC = SignInViewController()
                signInVC.modalPresentationStyle = .fullScreen
                self?.present(signInVC, animated: true)
            }
        }
        present(UINavigationController(rootViewController: vc),animated: true)
    }
    

}
