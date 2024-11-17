//
//  ProfilePresenterProtocol.swift
//  Image Feed
//
//  Created by Kaider on 12.11.2024.
//

import Foundation

protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    var profileService: ProfileService { get }
    var profileImageService: ProfileImageService { get }
    var tokenStorage: OAuth2TokenStorage { get }
    
    func viewDidLoad()
    func logout()
    func performLogout()
    func updateAvatar()
}
