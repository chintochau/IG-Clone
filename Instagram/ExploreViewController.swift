//
//  ExploreViewController.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import UIKit

class ExploreViewController: UIViewController, UISearchResultsUpdating {
    
    private var posts = [Post](), owners = [String]()
    
    private let searchVC = UISearchController(searchResultsController: SearchResultViewController())
    
    private let activityIndicator:UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.style = .large
        indicator.startAnimating()
        indicator.hidesWhenStopped = true
        indicator.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        return indicator
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewCompositionalLayout { index, _ -> NSCollectionLayoutSection? in
            // items
            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1/3),
                    heightDimension: .fractionalHeight(1)
                )
            )
            item.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)
            
            let fullItem = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1)
                )
            )
            fullItem.contentInsets = NSDirectionalEdgeInsets(top: 0.5, leading: 0.5, bottom: 0.5, trailing: 0.5)
            
            //group
            let verticalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1/3),
                    heightDimension: .fractionalHeight(1)
                ),
                subitem:fullItem,
                count: 2
            )
            
            
            
            let horizentalGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(2/3)
                ),
                subitems: [
                    item,
                    verticalGroup,
                    verticalGroup
                ]
            )
            
            let threeItemGroup = NSCollectionLayoutGroup.horizontal(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalHeight(1/3)
                ),
                subitem:fullItem,
                count: 3
            )
            
            let finalGroup = NSCollectionLayoutGroup.vertical(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1),
                    heightDimension: .fractionalWidth(1)
                ),
                subitems: [
                    horizentalGroup,
                    threeItemGroup
                ]
            )
            //section
            return NSCollectionLayoutSection(group: finalGroup)
        }
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(PhotoCollectionViewCell.self, forCellWithReuseIdentifier: PhotoCollectionViewCell.identifier)

        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Explore"
        
        view.backgroundColor = .systemBackground
        searchVC.searchBar.placeholder = "Search..."
        searchVC.searchResultsUpdater = self
        (searchVC.searchResultsController as? SearchResultViewController)?.delegate = self
        navigationItem.searchController = searchVC
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchData()
        
        view.addSubview(activityIndicator)
        activityIndicator.center = view.center
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.frame
    }
    
    private func fetchData(){
        DatabaseManager.shared.explorePosts { [weak self] posts in
            DispatchQueue.main.async{
                self?.posts = posts.compactMap({ result in
                    return result.post
                })
                self?.owners = posts.compactMap{ $0.owner }
                self?.collectionView.reloadData()
                self?.activityIndicator.stopAnimating()
            }
        }
    }
    
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let vc = searchController.searchResultsController as? SearchResultViewController,
        let query = searchController.searchBar.text,
        !query.trimmingCharacters(in: .whitespaces).isEmpty else {
            return
            
        }
        DatabaseManager.shared.findUsers(with: query) { results in
            DispatchQueue.main.async {
                vc.update(with: results)
            }
        }
        
        
        
    }
    
}

extension ExploreViewController:SearchResultViewControllerDelegate{
    func searchResultsViewController(_ vc: SearchResultViewController, didSelectResultWith user: User) {
        let vc = ProfileViewController(user: user)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension ExploreViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionViewCell.identifier, for: indexPath) as! PhotoCollectionViewCell
        
        cell.configure(with: URL(string: posts[indexPath.row].postUrlString))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
                return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let post = posts[indexPath.row], owner = owners[indexPath.row]
        let vc = PostViewController(post:post,username:owner)
        navigationController?.pushViewController(vc, animated: true)
        
    }
     
    
    
}
