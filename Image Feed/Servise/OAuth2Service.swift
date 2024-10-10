//
//  OAuth2Service.swift
//  Image Feed
//
//  Created by Kaider on 25.09.2024.
//

import Foundation

enum AuthServiceError: Error {
    case invalidRequest
    case noData
}

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
    
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Initializers
    
    private init() {}
    
    // MARK: - OAuth Token Request
    
    // Создание URLRequest для получение токена
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        
        guard let url = URL(string: "...\(code)") else {
            assertionFailure("Failed to create URL")
            return nil
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    // MARK: - Fetch OAuth Token
    
    // Получение токена от сервера по переданному авторизационному коду
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, any Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                
                // Обработка результата запроса
                defer {
                    self?.task = nil
                    self?.lastCode = nil
                }
                
                if let error = error {
                    print("OAuth2Service: \(error.localizedDescription)")
                    completion(.failure(error))
                    return
                }
                
                guard let data = data else {
                    completion(.failure(AuthServiceError.noData))
                    return
                }
                
                do {
                    guard let self = self else {
                        completion(.failure(AuthServiceError.invalidRequest))
                        return
                    }
                    let oAuthTokenResponseBody = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    print("OAuth2Service: \(oAuthTokenResponseBody)")
                    print(oAuthTokenResponseBody)
                    print(oAuthTokenResponseBody.accessToken)
                    self.authToken = oAuthTokenResponseBody.accessToken
                    completion(.success(oAuthTokenResponseBody.accessToken))
                } catch {
                    print("OAuth2Service: Decoding error: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }
    }
}
 
