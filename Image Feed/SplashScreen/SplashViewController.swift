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
    private let profileService = ProfileService.shared // Использование синглтона
    private let profileImageService = ProfileImageService.shared
    
    private enum SplashViewControllerConstants {
        static let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    }
    
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            print("Токен существует, переключение на TabBarController") // Лог ошибок
            fetchProfile(token)
        } else {
            print("Токен не найден, выполняется переход к экрану аутентификации") // Лог ошибок
            performSegue(withIdentifier: SplashViewControllerConstants.showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == SplashViewControllerConstants.showAuthenticationScreenSegueIdentifier {
            
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else {
                assertionFailure("Failed to prepare for \(SplashViewControllerConstants.showAuthenticationScreenSegueIdentifier)")
                return
            }
            print("Подготовка к переходу на AuthViewController") // Лог ошибок
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - AuthViewControllerDelegate
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        print("Аутентифицирован с помощью кода в SplashViewController: \(code)") // Лог ошибок
        dismiss(animated: true) { [weak self] in
            guard let self = self else {
                print("SplashViewController: Self равен нулю") // Лог ошибок
                return
            }
            self.fetchOAuthToken(code)
        }
    }
    
    // MARK: - Private Methods
    
    private func switchToTabBarController() {
        // Получаем экземпляр `window` приложения
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }
        // Создаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        // Установим в `rootViewController` полученный контроллер
        print("Переключение на TabBarController") // Лог ошибок
        window.rootViewController = tabBarController
    }
    
    private func fetchOAuthToken(_ code: String) {
        print("Извлечение токена OAuth с помощью кода: \(code)") // Лог ошибок
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.show()
                guard let self else {
                    print("SplashViewController: равен нулю") // Лог ошибок
                    preconditionFailure("Weak self error") }
                switch result {
                case .success(let token):
                    self.fetchProfile(token)
                case .failure(let error):
                    print("Ошибка извлечения токена \(error)") // Лог ошибок
                    UIBlockingProgressHUD.dismiss()
                }
            }
        }
    }
    
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true) { [weak self] in

            guard let self = self else {
                print("SplashViewController: Self равен нулю") // Лог ошибок
                           return
            }
            
            guard let token = self.storage.token else {
                print("SplashViewController: Токен не найден") // Лог ошибок
                return
            }
            self.fetchProfile(token)
        }
    }
    
    private func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            
            switch result {
            case .success(let profileResult):
                let profile = ProfileService.Profile(
                    username: profileResult.username,
                    name: profileResult.name,
                    loginName: "@" + profileResult.username,
                    bio: profileResult.bio
                )
                print("SplashViewController: Получен профиль для пользователя: \(profile.username)") // Лог получения профиля
                
                // Вызов метода для получения URL изображения профиля
                ProfileImageService.shared.fetchProfileImageURL(username: profileResult.username) { imageResult in
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
    
    // Алерт ошибки
    private func showAlert(with error: Error) {
        let alert = UIAlertController(
            title: "Ошибка получения профиля",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        // Возвращаемся к экрану авторизации
        let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.performSegue(withIdentifier: SplashViewControllerConstants.showAuthenticationScreenSegueIdentifier, sender: nil)
                }
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}

