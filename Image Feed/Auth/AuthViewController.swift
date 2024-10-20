//
//  AuthViewController.swift
//  Image Feed
//
//  Created by Kaider on 23.09.2024.
//

import UIKit
import ProgressHUD

protocol AuthViewControllerDelegate: AnyObject {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String)
    func didAuthenticate(_ vc: AuthViewController)
}

final class AuthViewController: UIViewController, WebViewViewControllerDelegate {
    
    private let ShowWebViewSegueIdentifier = "ShowWebView"
    private let oauth2Service = OAuth2Service.shared
    private let storage = OAuth2TokenStorage()
    
    weak var delegate: AuthViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
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
    
    private func showAlert(in viewController: UIViewController) {
        let alert = UIAlertController(title: "Что-то пошло не так(", message: "Не удалось войти в систему", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
    
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        UIBlockingProgressHUD.show()
        delegate?.authViewController(self, didAuthenticateWithCode: code)
        
        oauth2Service.fetchOAuthToken(code) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                UIBlockingProgressHUD.dismiss()
                
                switch result {
                case .success(let token):
                    print("AuthViewController: Успешно авторизован: \(token)")
                    self.delegate?.didAuthenticate(self)
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
