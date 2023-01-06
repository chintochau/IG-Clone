//
//  SearchResultViewController.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-04.
//

import UIKit

protocol SearchResultViewControllerDelegate:AnyObject {
    func searchResultsViewController(_ vc:SearchResultViewController,didSelectResultWith user:User)
}

class SearchResultViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    public weak var delegate:SearchResultViewControllerDelegate?
    
    private let tableView:UITableView = {
        let tableView = UITableView()
        tableView.isHidden = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    var users = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    public func update(with results:[User]) {
        users = results
        tableView.reloadData()
        tableView.isHidden = users.isEmpty
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = users[indexPath.row].username
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        self.delegate?.searchResultsViewController(self, didSelectResultWith: users[indexPath.row])
    }
    
    
}
