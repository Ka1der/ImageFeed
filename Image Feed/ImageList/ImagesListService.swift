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
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int = 0
    private var task: URLSessionTask?
    private let perPage = 10
    private let storage = OAuth2TokenStorage()
    
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
                self?.task = nil
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("\(#file):\(#line)] \(#function) Код ответа: \(httpResponse.statusCode)")
            }
            
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .useDefaultKeys
                    
                    let photoResults = try decoder.decode([PhotoResult].self, from: data)
                    DispatchQueue.main.async {
                        var newPhotos: [Photo] = []
                        for result in photoResults {
                            guard
                                let thumbURL = URL(string: result.urls.thumb),
                                let largeURL = URL(string: result.urls.full)
                            else {
                                print("\(#file):\(#line)] \(#function) Ошибка создания URL для фото id: \(result.id)")
                                continue
                            }
                        
                        let photo = Photo(
                                id: result.id,
                                size: CGSize(width: result.width, height: result.height),
                                createdAt: {
                                    if let dateString = result.createdAt {
                                        return self?.dateFormatter.date(from: dateString)
                                    }
                                    return nil
                                } (),
                                welcomeDescription: result.description,
                                thumbImageURL: thumbURL,
                                largeImageURL: largeURL,
                                isLiked: result.likedByUser
                            )
                        newPhotos.append(photo)
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
                        self?.task = nil
                    }
                } catch {
                    print("\(#file):\(#line)] \(#function) Ошибка декодирования: \(error)")
                    if let dataString = String(data: data, encoding: .utf8) {
                        print("Полученные данные: \(dataString)")
                    }
                    self?.task = nil
                }
            } else {
                self?.task = nil
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
        
        let urlString = "https://api.unsplash.com/photos/\(photoId)/like"
        guard let url = URL(string: urlString) else {
            print("[\(#file):\(#line)] \(#function) Invalid URL: \(urlString)")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
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
