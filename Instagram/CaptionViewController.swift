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
        
        
        
    }
    
    override func viewDidLayoutSubviews() {
        imageView.frame = CGRect(x: 10 , y: view.safeAreaInsets.top+10, width: view.width/4, height: view.width/4)
        textView.frame = CGRect(x: imageView.right+3, y: view.safeAreaInsets.top+10, width: view.width*3/4, height: view.width/4)
    }
    

    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = nil
    }

}
