//
//  OAuth2Service.swift
//  Image Feed
//
//  Created by Kaider on 25.09.2024.
//

import Foundation

final class OAuth2Service {
    
    // Создание URLRequest для получение токена
    func makeOAuthTokenRequest(code: String) -> URLRequest {
        guard var urlComponents = URLComponents(string: OAuth2ServiceConstants.unsplashGetTokenURLString) else {
            preconditionFailure("Invalid URL")
        }
        // Параметры запроса
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.AccessKey),
            URLQueryItem(name: "client_secret", value: Constants.SecretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.RedirectURI),
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
}
