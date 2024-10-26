//
//  OAuth2TokenStorage.swift
//  Image Feed
//
//  Created by Kaider on 25.09.2024.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    
    var token: String? {
        get {
            KeychainWrapper.standard.string(forKey: Keys.token.rawValue)
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: Keys.token.rawValue)
            } else {
                KeychainWrapper.standard.removeObject(forKey: Keys.token.rawValue)
            }
        }
    }
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case token
    }
}
