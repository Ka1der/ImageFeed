//
//  SplashViewController.swift
//  Image Feed
//
//  Created by Kaider on 29.09.2024.
//

import UIKit

final class SplashViewController: UIViewController, AuthViewControllerDelegate {
    
    // MARK: - Private Properties
    
    private let oauth2Service = OAuth2Service.shared
    private let storage = OAuth2TokenStorage()
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private enum SplashViewControllerConstants {
        static let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    }
    
    // MARK: - UI Elements
    
    private let splashScreenLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "SplashScreenLogo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    } ()
    
    // MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(splashScreenLogo)
        setupCostraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            print("SplashViewController: Токен существует, переключение на TabBarController") // Лог ошибок
            fetchProfile(token)
        } else {
            print("SplashViewController: Токен не найден, выполняется переход к экрану аутентификации") // Лог ошибок
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let viewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
                return
            }
            viewController.delegate = self
            viewController.modalPresentationStyle = .fullScreen
            present(viewController, animated: true)
        }
    }
    
    // MARK: - AuthViewControllerDelegate
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        print("Аутентифицирован с помощью кода в SplashViewController: \(code)") // Лог ошибок
    }
    
    // MARK: - Private Methods
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        print("SplashViewController: Переключение на TabBarController") // Лог ошибок
        window.rootViewController = tabBarController
    }
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true, completion: nil)
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let profileResult):
                let profile = ProfileModels.Profile(
                    username: profileResult.username,
                    name: profileResult.name,
                    loginName: "@" + profileResult.username,
                    bio: profileResult.bio
                )
                print("SplashViewController: Получен профиль для пользователя: \(profile.username)") // Лог получения профиля
                
                ProfileImageModels.shared.fetchProfileImageURL(username: profileResult.username, in: self) { imageResult in
                    switch imageResult {
                    case .success(let url):
                        print("SplashViewController: URL изображения профиля: \(url)") // Лог успешного получения URL
                        
                    case .failure(let error):
                        print("SplashViewController: Ошибка получения URL изображения профиля: \(error.localizedDescription)") // Лог ошибки
                    }
                }
                
                self.switchToTabBarController()
                print("SplashViewController: Авторизация прошла успешно для пользователя: \(profile.username)") // Лог успешной авторизации
            case .failure(let error):
                print("SplashViewController: Ошибка получения профиля: \(error.localizedDescription)") // Лог ошибки
                self.showAlert(with: error)
            }
        }
    }
    
    private func showAlert(with error: Error) {
        let alert = UIAlertController(
            title: "Ошибка получения профиля",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.performSegue(withIdentifier: SplashViewControllerConstants.showAuthenticationScreenSegueIdentifier, sender: nil)
        }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func setupCostraints() {
        NSLayoutConstraint.activate([
            splashScreenLogo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashScreenLogo.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

