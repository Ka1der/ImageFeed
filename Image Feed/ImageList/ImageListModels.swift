//
//  ImageListModels.swift
//  Image Feed
//
//  Created by Kaider on 27.10.2024.
//

import Foundation

    struct Photo {
        let id: String
        let size: CGSize
        let isLiked: Bool
    }
    
    struct PhotoResult: Codable {
        let id: String
        let width: Int
        let height: Int
        let likes: Int
        let likedByUser: Bool
    }
    
    struct UrlsResult {
        let raw: String
        let full: String
        let regular: String
        let small: String
        let thumb: String
    }

