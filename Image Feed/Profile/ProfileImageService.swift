//
//  ProfileImageService.swift
//  Image Feed
//
//  Created by Kaider on 19.10.2024.
//

import Foundation
import UIKit

final class ProfileImageService {
    
    // MARK: - Singleton
    static let shared = ProfileImageService()
    private init() {}
    
    // MARK: - Private Properties
    private(set) var avatarURL: String?
    private var task: URLSessionTask?
    private let decoder = SnakeCaseJSONDecoder()
    private let urlSession: URLSession = .shared
    private let storage = OAuth2TokenStorage()
    
    // MARK: - Public Properties
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageService.didChangeNotification")
    
    // MARK: - Public Methods
  func makeAvatarRequest(username: String) -> URLRequest? {
        guard let url = URL(string: "users/\(username)", relativeTo: Constants.defaultBaseURL)
        else {
            print ("ProfileService: неправильный URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        guard let token = storage.token else {
            print("ProfileImageService: Неправильный токен")
            return nil
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("ProfileImageService: Создан запрос с токеном: \(token)") // Лог ошибок
        return request
    }

}
