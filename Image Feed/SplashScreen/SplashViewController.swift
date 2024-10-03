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
        
        if storage.token != nil {
            print("Token exists, switching to TabBarController") // Лог ошибок
            switchToTabBarController()
        } else {
            print("Token not found, performing segue to authentication screen") // Лог ошибок
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
            print("Preparing for segue to AuthViewController") // Лог ошибок
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - AuthViewControllerDelegate
    
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        print("Authenticated with code in SplashViewController: \(code)") // Лог ошибок
        dismiss(animated: true) { [weak self] in
            guard let self = self else {
                print("SplashViewController: Self is nil") // Лог ошибок
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
        print("Switching to TabBarController") // Лог ошибок
        window.rootViewController = tabBarController
    }
    
    private func fetchOAuthToken(_ code: String) {
        print("Fetching OAuth token with code: \(code)") // Лог ошибок
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            guard let self else {
                print("SplashViewController: Self is nil") // Лог ошибок
                preconditionFailure("Weak self error") }
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure(let error):
                print("fetch token error \(error)") // Лог ошибок
            }
        }
    }
}

