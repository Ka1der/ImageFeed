//
//  ImageListPresenterProtocol.swift
//  Image Feed
//
//  Created by Kaider on 12.11.2024.
//

import Foundation

protocol ImageListPresenterProtocol {
    var view: ImageListViewControllerProtocol? { get set }
    var photos: [Photo] { get }
    
    func viewDidLoad()
    func fetchPhotosNextPage()
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void)
}
