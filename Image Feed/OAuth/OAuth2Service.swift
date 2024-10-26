//
//  OAuth2Service.swift
//  Image Feed
//
//  Created by Kaider on 25.09.2024.
//

import Foundation
import UIKit

enum AuthServiceError: Error {
    case invalidRequest
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
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard var urlComponents = URLComponents(string: OAuth2ServiceConstants.unsplashGetTokenURLString) else {
            print("OAuth2Service: Неверный URL для запроса токена") // Лог ошибки
            assertionFailure("Invalid URL")
            return nil
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
        ]
        
        guard let url = urlComponents.url else {
            print("OAuth2Service: Не удалось создать URL с параметрами") // Лог ошибки
            assertionFailure("Invalid URL after adding query items")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        print("OAuth2Service:\(request)") // Лог ошибок
        return request
    }
    // MARK: - Fetch OAuth Token
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Result<String, any Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        print("OAuth2Service: Запомнили code который использовался в запросе") // Лог ошибок
        
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("OAuth2Service: запрос на получение токена не создан") // Лог ошибок
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.data(for: request) { [weak self] result in
            DispatchQueue.main.async {
                guard let self else {
                    print("OAuth2Service: Self is nil") // Лог ошибок
                    preconditionFailure("Self is nil")
                }
                
                switch result {
                case .success(let data):
                    do {
                        let OAuthTokenResponseBody = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                        print("OAuth2Service:\(OAuthTokenResponseBody)")
                        print("OAuth2Service: \(OAuthTokenResponseBody.accessToken)")
                        self.authToken = OAuthTokenResponseBody.accessToken
                        completion(.success(OAuthTokenResponseBody.accessToken))
                    } catch {
                        print("OAuth2Service: ошибка декодирования: \(error.localizedDescription)") // Лог ошибок
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("OAuth2Service:\(error.localizedDescription)") // Лог ошибок
                    completion(.failure(error))
                }
                self.task = nil
                print("Обнуляем task") // Лог ошибок
                self.lastCode = nil
                print("Удаляем lastCode") // Лог ошибок
            }
            
        }
        self.task = task
        task.resume()
    }
}
