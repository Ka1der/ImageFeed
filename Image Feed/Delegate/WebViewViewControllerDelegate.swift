//
//  WebViewViewControllerDelegate.swift
//  Image Feed
//
//  Created by Kaider on 25.09.2024.
//

import Foundation

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}
