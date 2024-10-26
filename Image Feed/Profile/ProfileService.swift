//
//  ProfileService.swift
//  Image Feed
//
//  Created by Kaider on 12.10.2024.
//

import Foundation

final class ProfileService {
    
    // MARK: - Singleton
    static let shared = ProfileService()
    
    private init() {}
    
    // MARK: - Private Properties
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    private(set) var profile: ProfileModels.Profile?
    
    // MARK: - Public Methods
    func fetchProfile(_ token: String, completion: @escaping (Result<ProfileModels.Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let request = makeRequest(token: token) else {
            print("ProfileService: Невозможно создать запрос.")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileModels.ProfileResult, Error>) in
           
            guard self != nil else { return }
            
            switch result {
            case .success(let profileResult):
                print("ProfileService: Успешно получен профиль") // Лог
                let profile = ProfileModels.Profile(
                    username: profileResult.username,
                    name: profileResult.name ?? " ",
                    loginName: "@" + profileResult.username,
                    bio: profileResult.bio ?? " "
                )
                print("ProfileService: Создан объект Profile") // Лог
                completion(.success(profile))
                
            case .failure(let error):
                print("ProfileService: Ошибка: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
    // MARK: - Private Methods
 private func makeRequest(token: String) -> URLRequest? {
        guard let url = URL(string: "me", relativeTo: Constants.defaultBaseURL)
        else {
            print ("ProfileService: неправильный URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print("ProfileService: Создан запрос с токеном: \(token)") // Лог ошибок
        return request
    }
}
