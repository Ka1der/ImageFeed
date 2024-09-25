//
//  OAuth2Service.swift
//  Image Feed
//
//  Created by Kaider on 25.09.2024.
//

import Foundation

final class OAuth2Service {
    
    // Константы для OAuth2
    private let tokenURLString = "https://example.com/oauth/token"
    private let clientID = "your_client_id"
    private let clientSecret = "your_client_secret"
    private let redirectURI = "your_redirect_uri"
    private let grantType = "authorization_code"
    
    // Функция для создания URLRequest
    private func createTokenRequest(code: String) -> URLRequest? {
        guard let tokenURL = URL(string: tokenURLString) else {
            print("Невозможно создать URL")
            return nil
        }
        
        let bodyParameters = [
            "grant_type": grantType,
            "code": code,
            "redirect_uri": redirectURI,
            "client_id": clientID,
            "client_secret": clientSecret
        ]
        
        let bodyString = bodyParameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
        
        guard let httpBody = bodyString.data(using: .utf8) else {
            print("Невозможно создать тело запроса")
            return nil
        }
        
        var request = URLRequest(url: tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = httpBody
        
        return request
    }
    
    // Функция для выполнения сетевого запроса
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, Error>) -> Void) {
        
        // Создание URLRequest
        guard let request = createTokenRequest(code: code) else {
            completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка при создании запроса"])))
            return
        }
        
        // Выполнение сетевого запроса
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Нет данных в ответе"])))
                return
            }
            
            // Попытка декодировать ответ
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let token = json["access_token"] as? String {
                    completion(.success(token))
                } else {
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Ошибка в формате ответа"])))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
