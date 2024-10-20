//
//  URLSession+data.swift
//  Image Feed
//
//  Created by Kaider on 25.09.2024.
//

import Foundation
import UIKit

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case noData
}

// MARK: -  Обработка HTTP-статуса и ошибок
extension URLSession {
    
    func data(
        for request: URLRequest,
        in viewController: UIViewController,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data))
                } else {
                    self.showAlert(in: viewController) // Алерт при ошибке статуса
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                }
            } else if let error = error {
                self.showAlert(in: viewController) // Алерт при ошибке запроса
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
            } else {
                self.showAlert(in: viewController) // Алерт при общей ошибке
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
            }
        })
        return task
    }
    
    func objectTask<T: Decodable>(
        for request: URLRequest,
        in viewController: UIViewController,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        
        let decoder = SnakeCaseJSONDecoder() // Декодер snake_case в camelCase
        let task = data(for: request, in: viewController) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                do {
                    // Декодирование данных в тип T
                    let response = try decoder.decode(T.self, from: data)
                    // Выполнение завершения на главном потоке
                    DispatchQueue.main.async {
                        completion(.success(response))
                    }
                } catch {
                    // Логирование ошибки декодирования
                    print("URLSession+data: Ошибка декодирования \(error.localizedDescription)") // Лог ошибок
                    print("URLSession+data: Данные ответа \(String(data: data, encoding: .utf8) ?? "N/A")")
                    // Завершение с ошибкой декодирования
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            case .failure(let error):
                // Логирование сетевой ошибки
                print("URLSession+data: Ошибка сети \(error.localizedDescription)") // Лог ошибок
                // Завершение с сетевой ошибкой
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        return task
    }
    
    private func showAlert(in viewController: UIViewController) {
        let alert = UIAlertController(title: "Что-то пошло не так(", message: "Не удалось войти в систему", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}
