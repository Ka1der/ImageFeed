//
//  ProfileViewControllerProtocol.swift
//  Image Feed
//
//  Created by Kaider on 12.11.2024.
//

import Foundation

protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfileDetails(profile: ProfileModels.Profile)
    func updateAvatar(url: URL?)
    func showLogoutAlert()
}
