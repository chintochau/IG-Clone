//
//  SettingViewController.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import UIKit

class SettingViewController: UIViewController {
    
    private let tableView:UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
        
    }()
    
    public var completion: (() -> Void)?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        view.backgroundColor = .systemBackground
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector( didTapClose))
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        createTableFooter()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func createTableFooter(){
        let footer = UIView(frame: CGRect(x: 0, y: 0, width: view.width, height: 50))
        footer.clipsToBounds = true
        
        let button = UIButton(frame: footer.bounds)
        button.setTitle("Sign Out", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        button.addTarget(self, action: #selector(didTapSignOut), for: .touchUpInside)
        footer.addSubview(button)
        tableView.tableFooterView = footer
    }
    
    @objc private func didTapSignOut(){
        
        let actionSheet = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Sign Out", style: .destructive,handler: { [weak self] _ in
            // signout
            AuthManager.shared.signOut { success in
                if success {
                    DispatchQueue.main.async {
                        /// to prevent retain cycle (login, logout, login, logout)
                        self?.dismiss(animated: true)
                        self?.completion?()

//                        let vc = SignInViewController()
//                        let navVc = UINavigationController(rootViewController: vc)
//                        navVc.modalPresentationStyle = .fullScreen
//                        self?.present(navVc, animated: false)
                    }
                }
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(actionSheet, animated: true)
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
