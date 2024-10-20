//
//  Untitled.swift
//  Image Feed
//
//  Created by Kaider on 20.10.2024.
//

import Foundation

final class ProfileImageServiceObserver {
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    
    init() {
        
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.updateAvatar()
        }
        updateAvatar()
    }
    
    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    private func updateAvatar() {
        guard
                let profileImageURL = ProfileImageService.shared.avatarURL,
                let url = URL(string: profileImageURL)
        else { return }
        // TO-DO [Sprint 11] Обновить аватар, используя Kingfisher
    }
}
