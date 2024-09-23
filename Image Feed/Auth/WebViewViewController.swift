//
//  WebViewViewController.swift
//  Image Feed
//
//  Created by Kaider on 23.09.2024.
//
import WebKit
import UIKit

final class WebViewViewController: UIViewController {
    
    weak var delegate: WebViewViewControllerDelegate?
    
    @IBOutlet var webView: WKWebView!
    
    @IBAction func didTapBackButton(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
    }
    
    enum WebViewConstants {
        static let UnsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadAuthView()
        webView.navigationDelegate = self
    }
    
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.UnsplashAuthorizeURLString) else {
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            return
        }
        
        
        let request = URLRequest(url: url)
        webView.load(request)
        
    }
    
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
    decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            //TODO: pocess code
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/autorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: { $0.name == "code"})
        {
            return codeItem.value
        } else {
            return nil
        }
    }
    
}

extension WebViewViewController: WKNavigationDelegate {
    }

