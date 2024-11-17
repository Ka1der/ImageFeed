//
//  ImageListPresenterSpy.swift
//  Image FeedTests
//
//  Created by Kaider on 14.11.2024.
//

import Foundation
@testable import Image_Feed

final class ImageListPresenterSpy: ImageListPresenterProtocol {
    var view: ImageListViewControllerProtocol?
    var photos: [Photo] = []
    
    var viewDidLoadCalled = false
    var fetchPhotosNextPageCalled = false
    var changeLikeCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func fetchPhotosNextPage() {
        fetchPhotosNextPageCalled = true
    }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        changeLikeCalled = true
        completion(.success(()))
    }
}
