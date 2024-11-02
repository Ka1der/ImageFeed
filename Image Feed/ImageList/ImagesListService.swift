//
//  ImagesListService.swift
//  Image Feed
//
//  Created by Kaider on 27.10.2024.
//

import Foundation

final class ImagesListService {
    // MARK: - Properties
    static let shared = ImagesListService()
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int = 0
    private var task: URLSessionTask?
    private let perPage = 10
    private let storage = OAuth2TokenStorage()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Private Properties
    
    private let dateFormatter: ISO8601DateFormatter = {
          let formatter = ISO8601DateFormatter()
          return formatter
      }()
    
    // MARK: - Public Methods
    func fetchPhotosNextPage() {
        guard task == nil else {
            print("[\(#file):\(#line)] \(#function) Фотографии уже загружаются")
            return
        }
        
        guard let token = storage.token else {
            print("[\(#file):\(#line)] \(#function) Токен отсутствует")
            return
        }
        
        let nextPage = lastLoadedPage + 1
        let urlString = "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(perPage)"
        
        guard let url = URL(string: urlString) else {
            print("\(#file):\(#line)] \(#function) Invalid URL: \(urlString)")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("\(#file):\(#line)] \(#function) Ошибка запроса: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("\(#file):\(#line)] \(#function) Код ответа: \(httpResponse.statusCode)")
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .useDefaultKeys // Используем дефолтную стратегию
                    
                    let photoResults = try decoder.decode([PhotoResult].self, from: data)
                    DispatchQueue.main.async {
                        let newPhotos = photoResults.map { result in
                            Photo(
                                id: result.id,
                                size: CGSize(width: result.width, height: result.height),
                                createdAt: self?.dateFormatter.date(from: result.createdAt), // Парсим дату
                                welcomeDescription: result.description,
                                thumbImageURL: result.urls.thumb,
                                largeImageURL: result.urls.full,
                                isLiked: result.likedByUser
                            )
                        }
                        
                        self?.photos.append(contentsOf: newPhotos)
                        self?.lastLoadedPage = nextPage
                        
                        NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                            object: self,
                            userInfo: ["photos": newPhotos]
                        )
                        
                        print("Загружено \(newPhotos.count) новых фото")
                        newPhotos.forEach { photo in
                            print("URL превью: \(photo.thumbImageURL)")
                        }
                    }
                } catch {
                    print("\(#file):\(#line)] \(#function) Ошибка декодирования: \(error)")
                    if let dataString = String(data: data, encoding: .utf8) {
                        print("Полученные данные: \(dataString)")
                    }
                }
            }
        }
        
        self.task = task
        task.resume()
    }
    
    // MARK: - Change Like Status
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        
        guard let token = storage.token else {
            print("\(#file):\(#line)] \(#function) Токен отсутствует")
            return
        }
        
        // url для запроса лайков
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            print("[\(#file):\(#line)] \(#function) Invalid URL: \(urlString)")
            return
        }
        
        // создаем запрос
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // делаем запрос
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                let isSuccess = (200...299).contains(httpResponse.statusCode)
                if isSuccess {
                    if let index = self?.photos.firstIndex(where: { $0.id == photoId }) {
                        self?.photos[index].isLiked = isLike
                    }
                    DispatchQueue.main.async {
                        completion(.success(()))
                    }
                } else {
                    print("Ошибка HTTP: \(httpResponse.statusCode)")
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.httpStatusCode(httpResponse.statusCode)))
                    }
                }
            }
        }
        task.resume()
    }
}
