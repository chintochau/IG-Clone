//
//  SignInViewController.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import UIKit
import SafariServices

class SignInViewController: UIViewController {
    
    private let headerView = SignInHeaderView()
    
    private let emailTextField:IGTextField = {
        let textField = IGTextField()
        textField.placeholder = "Email Address"
        textField.text = "jj@jj.com"
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .next
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let passwordField:IGTextField = {
        let textField = IGTextField()
        textField.placeholder = "Password"
        textField.text = "password"
        textField.keyboardType = .default
        textField.returnKeyType = .continue
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let signInButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign In", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        
        return button
    }()
    private let createAccountButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    private let termsButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Terms", for: .normal)
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    private let privacyButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Privacy Policy", for: .normal)
        button.setTitleColor(.link, for: .normal)
        return button
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        addSubviews()
        emailTextField.delegate = self
        passwordField.delegate = self
        signInButton.addTarget(self, action: #selector(didTapSignInButton), for: .touchUpInside)
        createAccountButton.addTarget(self, action: #selector(didTapCreateAccountButton), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(didTapTermsButton), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(didTapPrivacyButton), for: .touchUpInside)
        
        
    }
    
    
    
    private func addSubviews(){
        view.addSubview(headerView)
        view.addSubview(emailTextField)
        view.addSubview(passwordField)
        view.addSubview(signInButton)
        view.addSubview(createAccountButton)
        view.addSubview(termsButton)
        view.addSubview(privacyButton)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        headerView.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height/4)
        emailTextField.frame = CGRect(x: 20, y: headerView.bottom+20, width: view.width - 40, height: 50)
        passwordField.frame = CGRect(x: 20, y: emailTextField.bottom+15, width: view.width - 40, height: 50)
        signInButton.frame = CGRect(x: 35, y: passwordField.bottom+20, width: view.width - 70, height: 50)
        createAccountButton.frame = CGRect(x: 35, y: signInButton.bottom+20, width: view.width - 70, height: 30)
        termsButton.frame = CGRect(x: 35, y: view.height-150, width: view.width - 70, height: 30)
        privacyButton.frame = CGRect(x: 35, y: termsButton.bottom, width: view.width - 70, height: 30)
        
    }
    
    
    @objc private func didTapSignInButton(){
        emailTextField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailTextField.text,
              let password = passwordField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 8 else {return}
        
        
        // perform signin
        AuthManager.shared.signIn(email: email, password: password) { [weak self] result in
            DispatchQueue.main.async{
                switch result {
                case .success:
                    let vc = TabBarViewController()
                    vc.modalPresentationStyle = .fullScreen
                    self?.present(vc,animated: true)
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    
    @objc private func didTapCreateAccountButton(){
        // navigate to signup page
        let vc = SignUpViewController()
        vc.title = "Create Account"
        vc.completion = { [weak self] in
            DispatchQueue.main.async {
                let tabVC = TabBarViewController()
                tabVC.modalPresentationStyle = .fullScreen
                self?.present(tabVC, animated: true)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    @objc private func didTapTermsButton(){
        // safari to terms page
        guard let url = URL(string: "https://help.instagram.com/581066165581870") else {return}
            
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
    }
    @objc private func didTapPrivacyButton(){
        // safari to terms page
        guard let url = URL(string: "https://privacycenter.instagram.com/policy") else {return}
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true)
        
    }
    
    
}

// MARK: - TextField Delegate
extension SignInViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField{
            passwordField.becomeFirstResponder()
            
        }else if textField == passwordField{
            textField.resignFirstResponder()
            didTapSignInButton()
        }
        
        return true
    }
}
