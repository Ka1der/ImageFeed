//
//  AuthViewController.swift
//  Image Feed
//
//  Created by Kaider on 23.09.2024.
//

import UIKit
import ProgressHUD

// MARK: - Protocols
protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    
    // MARK: - Constants
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    
    // MARK: - Private Properties
    private let oauth2Service = OAuth2Service.shared
    private let storage = OAuth2TokenStorage()
    
    // MARK: - Public Properties
    weak var delegate: AuthViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ShowWebViewSegueIdentifier {
            guard let webViewViewController = segue.destination as? WebViewViewController else {
                fatalError("Failed to prepare for \(ShowWebViewSegueIdentifier)")
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    // MARK: - Private Methods
    private func showAlert(in viewController: UIViewController) {
        let alert = UIAlertController(title: "Что-то пошло не так(", message: "Не удалось войти в систему", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - WebViewViewControllerDelegate
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        delegate?.authViewController(self, didAuthenticateWithCode: code)
        
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success(let token):
                    self.storage.token = token
                    print("AuthViewController: Успешно авторизован: \(token)")
                    self.dismiss(animated: true) { [weak self] in
                                        guard let self = self else { return }
                                        self.delegate?.didAuthenticate(self)
                                    }
                case .failure(let error):
                    print("AuthViewController Ошибка авторизации: \(error)")
                    self.showAlert(in: self)
                }
            }
        }
    }
    
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        dismiss(animated: true)
    }
}
