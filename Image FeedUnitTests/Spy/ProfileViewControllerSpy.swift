//
//  ProfileViewControllerSpy.swift
//  Image FeedTests
//
//  Created by Kaider on 14.11.2024.
//

@testable import Image_Feed
import Foundation

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
    var updateProfileDetailsCalled = false
    var updateAvatarCalled = false
    var showLogoutAlertCalled = false
    
    func updateProfileDetails(profile: ProfileModels.Profile) {
        updateProfileDetailsCalled = true
    }
    
    func updateAvatar(url: URL?) {
        updateAvatarCalled = true
    }
    
    func showLogoutAlert() {
        showLogoutAlertCalled = true
    }
}
