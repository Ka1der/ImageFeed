//
//  ProfileService.swift
//  Image Feed
//
//  Created by Kaider on 12.10.2024.
//

import Foundation

final class ProfileService {
    
    static let shared = ProfileService()
    
    private init() {} // Приватный инициализатор синглтона
    
    // Получение базовой информации о пользователе GET /me
    struct ProfileResult: Codable {
        let username: String
        let name: String?
        let firstName: String?
        let lastName: String?
        let bio: String?
        
//        var name: String { return "\(firstName) \(lastName)" }
//        var loginName: String { return "@\(username)" }
    }
    
    // Получение публичной информации о пользователе GET /users/:username
    struct Profile {
        let username: String
        let name: String
        let loginName: String
        let bio: String
    }
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask? // Переменная текущего запроса
    private var lastToken: String?
    private(set) var profile: Profile?
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread) // Проверяем работу в главном потоке
        task?.cancel()
        
        guard let request = makeRequest(token: token) else { // Создаем запрос
            print("ProfileService: Невозможно создать запрос.")
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
           
            guard self != nil else { return }
            
            switch result {
            case .success(let profileResult):
                print("ProfileService: Успешно получен профиль") // Лог
                let profile = Profile( // Создаем объект Profile
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
    
    // Вспомогательный метод для создания запроса
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
