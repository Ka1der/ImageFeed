//
//  OAuth2Service.swift
//  Image Feed
//
//  Created by Kaider on 25.09.2024.
//

import Foundation

final class OAuth2Service {
    
    // MARK: - Properties
    
    var authToken: String? {
        get {
            OAuth2TokenStorage().token
        }
        set {
            OAuth2TokenStorage().token = newValue
        }
    }
    
    static let shared = OAuth2Service()
    private let urlSession = URLSession.shared
    private let decoder = JSONDecoder()
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - OAuth Token Request
    
    // Создание URLRequest для получение токена
    func makeOAuthTokenRequest(code: String) -> URLRequest {
        guard var urlComponents = URLComponents(string: OAuth2ServiceConstants.unsplashGetTokenURLString) else {
            preconditionFailure("Invalid URL")
        }
        // Параметры запроса
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        // Проверка URL после добавления параметров
        guard let url = urlComponents.url else {
            preconditionFailure("Invalid URL")
        }
        // Создание URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        print(request)
        return request
    }
    
    // MARK: - Fetch OAuth Token
    
    // Получение токена от сервера по переданному авторизационному коду
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, any Error>) -> Void) {
       
        let request = makeOAuthTokenRequest(code: code)
        let task = urlSession.data(for: request) { [weak self] result in
            guard let self else { preconditionFailure("Self is nil")
            }
            
            // Обработка результата запроса
            switch result {
            case .success(let data):
                do {
                    let OAuthTokenResponseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    print(OAuthTokenResponseBody)
                    print(OAuthTokenResponseBody.accessToken)
                    self.authToken = OAuthTokenResponseBody.accessToken
                    completion(.success(OAuthTokenResponseBody.accessToken))
                } catch {
                    completion(.failure(error))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
