//
//  TabBarController.swift
//  Image Feed
//
//  Created by Kaider on 22.10.2024.
//

import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        configurateviewControllers()
        
    }
    
    // MARK: - Private Methods
    private func configurateviewControllers() {
    
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController")
        
        imagesListViewController.tabBarItem = UITabBarItem(
                   title: "",
                   image: UIImage(named: "tab_editorial_active"),
                   selectedImage: nil
               )
               
               let profileViewController = ProfileViewController()
               profileViewController.tabBarItem = UITabBarItem(
                   title: "",
                   image: UIImage(named: "tab_profile_active"),
                   selectedImage: nil
               )
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
