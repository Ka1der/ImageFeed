//
//  ImageListViewControllerProtocol.swift
//  Image Feed
//
//  Created by Kaider on 12.11.2024.
//

import Foundation

protocol ImageListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(withPhotos photos: [Photo])
    func showLikeError()
}
