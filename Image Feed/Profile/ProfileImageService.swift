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
    
    // MARK: - Models
    struct UserResult: Codable {
        let profileImage: [String: String]?
    }
    
    // MARK: - Private Methods
    private func makeAvatarRequest(username: String) -> URLRequest? {
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
    
    // MARK: - Public Methods
    func fetchProfileImageURL(username: String, in viewController: UIViewController, _ completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let request = makeAvatarRequest(username: username) else {
            print("ProfileImageService: Невозможно создать запрос.")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            guard let self = self else { return }
            
            switch result {
            case .success(let userResult):
                if let profileImage = userResult.profileImage?["large"] {
                    self.avatarURL = profileImage
                    completion(.success(profileImage))
                    print("ProfileImageService: Успешно получен URL для аватарки: \(profileImage)") // Лог ошибок
                    NotificationCenter.default.post(
                            name: ProfileImageService.didChangeNotification,
                            object: self,
                            userInfo: ["URL": profileImage])
                } else {
                    print("ProfileImageService: URL изображения профиля отсутствует.")
                    completion(.failure(NetworkError.noData)) // Лог ошибок
                }
            case .failure(let error):
                print("ProfileImageService: Ошибка при получении изображения профиля: \(error.localizedDescription)") // Лог ошибок
                print("result: \(result)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
}
