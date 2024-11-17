//
//  ImageListPresenter.swift
//  Image Feed
//
//  Created by Kaider on 12.11.2024.
//

import Foundation

final class ImageListPresenter: ImageListPresenterProtocol {
    weak var view: ImageListViewControllerProtocol?
    private let imagesService: ImagesListService
    private var imagesListServiceObserver: NSObjectProtocol?
    
    var photos: [Photo] {
        imagesService.photos
    }
    
    init(imagesService: ImagesListService = .shared) {
        self.imagesService = imagesService
    }
    
    func viewDidLoad() {
        setupObserver()
        fetchPhotosNextPage()
    }
    
    func fetchPhotosNextPage() {
        imagesService.fetchPhotosNextPage()
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        imagesService.changeLike(photoId: photoId, isLike: isLike, completion)
    }
    
    private func setupObserver() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            self?.updateTableView(notification)
        }
    }
    
    deinit {
        if let observer = imagesListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    @objc private func updateTableView(_ notification: Notification) {
        guard let newPhotos = notification.userInfo?["photos"] as? [Photo] else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.view?.updateTableViewAnimated(withPhotos: newPhotos)
        }
    }
}
