//
//  ProfileModels.swift
//  Image Feed
//
//  Created by Kaider on 26.10.2024.
//

import Foundation

final class ProfileModels {
    
    struct ProfileResult: Codable {
        let username: String
        let name: String?
        let firstName: String?
        let lastName: String?
        let bio: String?
    }
    
    struct Profile {
        let username: String
        let name: String
        let loginName: String
        let bio: String
    }
}
