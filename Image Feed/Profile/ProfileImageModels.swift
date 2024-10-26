//
//  ProfileImageModels.swift
//  Image Feed
//
//  Created by Kaider on 26.10.2024.
//

import UIKit

final class ProfileImageModels {
    
    // MARK: - Singleton
    static let shared = ProfileImageModels()
    private init() {}
   
    // MARK: - Private Properties
    private let makeAvatarRequestAccess = ProfileImageService.shared.makeAvatarRequest
    private let urlSession: URLSession = .shared
    private(set) var avatarURL: String?
    
    // MARK: - Models
    struct UserResult: Codable {
        let profileImage: [String: String]?
    }
    
    // MARK: - Public Methods
   func fetchProfileImageURL(username: String, in viewController: UIViewController, _ completion: @escaping (Result<String, Error>) -> Void) {
        
        guard let request = makeAvatarRequestAccess(username) else {
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
