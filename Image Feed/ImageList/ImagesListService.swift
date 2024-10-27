//
//  ImagesListService.swift
//  Image Feed
//
//  Created by Kaider on 27.10.2024.
//

import Foundation

final class ImagesListService {
    
    static let shared = ImagesListService()
    
    init() {}
    
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int = 0
    private var task: URLSessionTask?
    private let perPage = 10
    private let storage = OAuth2TokenStorage()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func fetchPhotosNextPage() {
        // Проверяем, не идёт ли уже закачка
        guard task == nil else {
            print("[\(#file):\(#line)] \(#function) Фотографии уже загружаются") // Лог ошибок
            return
        }
        
        guard let token = storage.token else {
            print("[\(#file):\(#line)] \(#function) Токен отсутствует") // Лог ошибок
            return
        }
        
        // Создаем URL для запроса
        let nextPage = lastLoadedPage + 1
        
        let urlString = "https://api.unsplash.com/photos?page=\(nextPage)&per_page=\(perPage)"
        guard let url = URL(string: urlString) else {
            print("\(#file):\(#line)] \(#function) Invalid URL: \(urlString)") // Лог ошибок
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
                   guard let self = self else { return }
                   
            defer {
                self.task = nil
            }
            
            switch result {
                       case .success(let photoResults):
                           // Преобразуем PhotoResult в Photo
                           let newPhotos = photoResults.map { result in
                               Photo(
                                   id: result.id,
                                   size: CGSize(width: result.width, height: result.height),
                                   isLiked: result.likedByUser
                               )
                           }
                           
                           self.photos.append(contentsOf: newPhotos)
                           self.lastLoadedPage = nextPage
                           NotificationCenter.default.post(
                            name: ImagesListService.didChangeNotification,
                               object: self,
                               userInfo: nil
                           )
                           
                       case .failure(let error):
                           print("[\(#file):\(#line)] \(#function) Failed to fetch photos: \(error)")
                       }
                   }
                   
                   self.task = task
                   task.resume()
               }
           }
    
    
    //    let photos = try SnakeCaseJSONDecoder().decode([PhotoResult].self, from: jsonData)
    
    //    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
//    func fetchPhotosNextPage(task: URLSessionTask?) {
//        
//        // Здесь получим страницу номер 1, если ещё не загружали ничего,
//        // и следующую страницу (на единицу больше), если есть предыдущая загруженная страница
////        let nextPage = (lastLoadedPage?.number ?? 0) + 1
//    }
//}
