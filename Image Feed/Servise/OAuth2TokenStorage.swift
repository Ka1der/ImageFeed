//
//  OAuth2TokenStorage.swift
//  Image Feed
//
//  Created by Kaider on 25.09.2024.
//

import Foundation

final class OAuth2TokenStorage {
    private let tokenKey = "OAuth2AccessToken"
    
    var token: String? {
        get {
            // Извлечение токена из UserDefaults
            return UserDefaults.standard.string(forKey: tokenKey)
        }
        set {
            // Сохранение токена в UserDefaults
            UserDefaults.standard.setValue(newValue, forKey: tokenKey)
        }
    }
    
    // Метод для удаления токена
    func removeToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }
}

