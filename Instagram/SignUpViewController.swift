//
//  SignInViewController.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import UIKit
import SafariServices

class SignUpViewController: UIViewController {
    
    private let profilePictureImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .label
        imageView.image = UIImage(systemName: "person.circle")
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 45
        return imageView
    }()
    
    private let emailTextField:IGTextField = {
        let textField = IGTextField()
        textField.placeholder = "Email Address"
        textField.text = "jj@jj.com"
        textField.keyboardType = .emailAddress
        textField.returnKeyType = .next
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let usernameField:IGTextField = {
        let textField = IGTextField()
        textField.placeholder = "Username"
        textField.text = "jjchau"
        textField.keyboardType = .default
        textField.returnKeyType = .next
        textField.autocorrectionType = .no
        return textField
    }()
    
    private let passwordField:IGTextField = {
        let textField = IGTextField()
        textField.placeholder = "Create Password"
        textField.text = "password"
        textField.keyboardType = .default
        textField.returnKeyType = .continue
        textField.autocorrectionType = .no
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let signUnButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign Up", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.label, for: .normal)
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        
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
    
    public var completion: (() -> Void)?
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Sign Up"
        addSubviews()
        usernameField.delegate = self
        emailTextField.delegate = self
        passwordField.delegate = self
        addButtonActions()
        addImageGesture()
    }
    
    
    
    private func addSubviews(){
        view.addSubview(profilePictureImageView)
        view.addSubview(usernameField)
        view.addSubview(emailTextField)
        view.addSubview(passwordField)
        view.addSubview(signUnButton)
        view.addSubview(termsButton)
        view.addSubview(privacyButton)
    }
    
    private func addButtonActions (){
        
        signUnButton.addTarget(self, action: #selector(didTapSignUpButton), for: .touchUpInside)
        termsButton.addTarget(self, action: #selector(didTapTermsButton), for: .touchUpInside)
        privacyButton.addTarget(self, action: #selector(didTapPrivacyButton), for: .touchUpInside)
        
    }
    
    private func addImageGesture(){
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapAddImage))
        gesture.numberOfTapsRequired = 1
        gesture.numberOfTouchesRequired = 1
        profilePictureImageView.isUserInteractionEnabled = true
        profilePictureImageView.addGestureRecognizer(gesture)
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let imageSize:CGFloat = 90
        profilePictureImageView.frame = CGRect(x: (view.width-90)/2, y: view.safeAreaInsets.top, width: imageSize, height: imageSize)
        usernameField.frame = CGRect(x: 20, y: profilePictureImageView.bottom+20, width: view.width - 40, height: 50)
        emailTextField.frame = CGRect(x: 20, y: usernameField.bottom+15, width: view.width - 40, height: 50)
        passwordField.frame = CGRect(x: 20, y: emailTextField.bottom+15, width: view.width - 40, height: 50)
        signUnButton.frame = CGRect(x: 35, y: passwordField.bottom+20, width: view.width - 70, height: 50)
        termsButton.frame = CGRect(x: 35, y: signUnButton.bottom + 100, width: view.width - 70, height: 30)
        privacyButton.frame = CGRect(x: 35, y: termsButton.bottom, width: view.width - 70, height: 30)
        
    }
    
    
    // MARK: - Button Action
    
    @objc private func didTapAddImage(){
        let sheet = UIAlertController(title: "Profile Image", message: "Set a Picture to help your friend find you.", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] _ in
            
            DispatchQueue.main.async{
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.allowsEditing = true
                picker.delegate = self
                self?.present(picker, animated: true)
            }
            
        }))
        sheet.addAction(UIAlertAction(title: "Choose Photo", style: .default,handler: { [weak self] _ in
            
            
            DispatchQueue.main.async{
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.allowsEditing = true
                picker.delegate = self
                self?.present(picker, animated: true)
            }
            
        }))
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(sheet, animated: true)
    }
    
    @objc private func didTapSignUpButton(){
        usernameField.resignFirstResponder()
        emailTextField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailTextField.text,
              let password = passwordField.text,
              let username = usernameField.text,
              !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty,
              password.count >= 8,
              username.count >= 2,
              username.trimmingCharacters(in: .alphanumerics).isEmpty else {
            
            presentError()
            return
            
        }
        
        let data = profilePictureImageView.image?.pngData()
        
        AuthManager.shared.signUp(email: email,username: username,password: password,profilePicture: data) { [weak self] result in
            DispatchQueue.main.async{
            switch result{
            case .success(let user):
                UserDefaults.standard.setValue(user.email, forKey: "email")
                UserDefaults.standard.setValue(user.username, forKey: "username")
                print(UserDefaults.standard.string(forKey: "username"))
                self?.navigationController?.popToRootViewController(animated: true)
                self?.completion?()
            case .failure(let error):
                print("\n\n Signup Error\(error)")
            }}
        }
    }
    
    private func presentError(){
        
        let alert = UIAlertController(title: "Oops~", message: "Please make sure to fill every field and make sure password is 8 Characters and longer.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
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
extension SignUpViewController:UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameField{
            emailTextField.becomeFirstResponder()
        }else if textField == emailTextField{
            passwordField.becomeFirstResponder()
            
        }else if textField == passwordField{
            textField.resignFirstResponder()
            didTapSignUpButton()
        }
        
        return true
    }
}

// MARK: - Image Picker Delegate
extension SignUpViewController:UIImagePickerControllerDelegate,  UINavigationControllerDelegate{
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true,completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {return}
        
        profilePictureImageView.image = image
        
    }
    
}
