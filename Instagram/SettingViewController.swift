//
//  SettingViewController.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import UIKit
import SafariServices

class SettingViewController: UIViewController {
    
    private let tableView:UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
        
    }()
    
    private var sections: [SettingsSection] = []
    
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
        
        configureModels()
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
    
    private func configureModels(){
        sections.append(
            SettingsSection(title: "App", options: [
                SettingOption(title: "Rate App", image: UIImage(systemName: "star"), color: .label, handler: {
                    
                    guard let url = URL(string: "https://apps.apple.com/us/app/instagram/id389801252") else {return}
                    UIApplication.shared.open(url)
                            
                }),
                SettingOption(title: "Share App", image: UIImage(systemName: "square.and.arrow.up"), color: .label, handler: { [weak self] in
                    
                    guard let url = URL(string: "https://apps.apple.com/us/app/instagram/id389801252") else {return}
                    let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
                    self?.present(vc, animated: true)
                    
                })
            ])
        )
        
        sections.append(
            SettingsSection(title: "Information", options: [
                SettingOption(title: "Terms of Service", image: UIImage(systemName: "doc"), color: .label, handler: {
                    
                    guard let url = URL(string: "https://help.instagram.com/581066165581870/?helpref=uf_share") else {return}
                    let vc = SFSafariViewController(url: url)
                    self.present(vc, animated: true)
                    
                }),
                SettingOption(title: "Privacy Policy", image: UIImage(systemName: "hand.raised"), color: .label, handler: {
                    guard let url = URL(string: "https://privacycenter.instagram.com/policy") else {return}
                    let vc = SFSafariViewController(url: url)
                    self.present(vc, animated: true)
                }),
                SettingOption(title: "Help", image: UIImage(systemName: "questionmark.circle"), color: .label, handler: {
                    guard let url = URL(string: "https://help.instagram.com") else {return}
                    let vc = SFSafariViewController(url: url)
                    self.present(vc, animated: true)
                })
            ])
        )
        
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
        return sections[section].options.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = sections[indexPath.section].options[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = model.title
        cell.imageView?.image = model.image
        cell.imageView?.tintColor = model.color
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let model = sections[indexPath.section].options[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        model.handler()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return sections[section].title
    }
    
}
