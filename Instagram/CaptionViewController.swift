//
//  CaptionViewController.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import UIKit

class CaptionViewController: UIViewController,UITextViewDelegate {
    
    private var image:UIImage
    
    private let imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    
    private let textView:UITextView = {
        let textView = UITextView()
        textView.text = "Add caption.."
        textView.backgroundColor = .secondarySystemBackground
        textView.textContainerInset = UIEdgeInsets(top: 3, left: 3, bottom: 3, right: 3)
        textView.font = .systemFont(ofSize: 20)
        return textView
    }()
    
    
    init(image:UIImage){
        self.image = image
        imageView.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(textView)
        textView.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: .done, target: self, action:#selector(didTapPost) )
    }
    
    @objc func didTapPost(){
        
        textView.resignFirstResponder()
        
        var caption = textView.text ?? ""
        if caption == "Add caption.." {caption = ""}
        // upload photo, update database
        
        //Post
        // generate post id
        guard let newPostID = createNewPostID(), let stringDate = String.date(from: Date()) else {return}
        // updload post
        StorageManager.shared.uploadPost(id: newPostID, data: image.pngData()) { newPostDownloadUrl in
            guard let url = newPostDownloadUrl else {
                print("failed to upload post")
                return}
            
            // new post
            let newPost = Post(id: newPostID, caption: caption, postedDate: stringDate, postUrlString: url.absoluteString, likers: [])
            
            // update database
            DatabaseManager.shared.createPost(newPost: newPost) { [weak self] success in
                guard success else {return}
                DispatchQueue.main.async{
                    self?.tabBarController?.tabBar.isHidden = false
                    self?.tabBarController?.selectedIndex = 0
                    self?.navigationController?.popToRootViewController(animated: false)
                    
                    NotificationCenter.default.post(name: .didPostNotification,
                                                    object: nil)
                    
                }
            }
            
        }
        
        
        
    }
    
    private func createNewPostID() -> String?{
        let timeStamp = Date().timeIntervalSince1970
        let randomNumber = Int.random(in: 0...1000)
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            return nil
        }
        return "\(username)_\(randomNumber)_\(timeStamp)"
        
        
    }
    
    override func viewDidLayoutSubviews() {
        imageView.frame = CGRect(x: 10 , y: view.safeAreaInsets.top+10, width: view.width/4, height: view.width/4)
        textView.frame = CGRect(x: imageView.right+3, y: view.safeAreaInsets.top+10, width: view.width*3/4, height: view.width/4)
    }
    

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = nil
    }

}
