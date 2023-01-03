//
//  TabBarViewController.swift
//  Instagram
//
//  Created by Jason Chau on 2023-01-02.
//

import UIKit

class TabBarViewController: UITabBarController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        //Define VC
        let home =          HomeViewController()
        let explore =       ExploreViewController()
        let camera =        CameraViewController()
        let notification =  NotificationViewController()
        let profile =       ProfileViewController()
        
        let nav1 = UINavigationController(rootViewController: home)
        let nav2 = UINavigationController(rootViewController: explore)
        let nav3 = UINavigationController(rootViewController: camera)
        let nav4 = UINavigationController(rootViewController: notification)
        let nav5 = UINavigationController(rootViewController: profile)
        
        // Define tab items
        nav1.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "house"), tag: 1)
        nav2.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "magnifyingglass"), tag: 2)
        nav3.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "plus"), tag: 3)
        nav4.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "heart"), tag: 4)
        nav5.tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "person"), tag: 5)
        
        // set controllers
        self.setViewControllers([nav1,nav2,nav3,nav4,nav5], animated: false)
        
    }
    


}
