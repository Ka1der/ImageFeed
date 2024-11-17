//
//  ProfilePresenterSpy.swift
//  Image FeedTests
//
//  Created by Kaider on 14.11.2024.
//

@testable import Image_Feed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol {
   var presenter: ProfilePresenterProtocol?
   weak var view: ProfileViewControllerProtocol?
   
   var viewDidLoadCalled = false
   var logoutCalled = false
   var performLogoutCalled = false
   var updateAvatarCalled = false
   
   var profileService: ProfileService = .shared
   var profileImageService: ProfileImageService = .shared
   var tokenStorage: OAuth2TokenStorage = .init()
   
   func viewDidLoad() {
       viewDidLoadCalled = true
   }
   
   func logout() {
       logoutCalled = true
   }
   
   func performLogout() {
       performLogoutCalled = true
   }
   
   func updateAvatar() {
       updateAvatarCalled = true
   }
}
