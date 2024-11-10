//
//  WebViewPresenterSpy.swift
//  Image FeedTests
//
//  Created by Kaider on 10.11.2024.
//

import Image_Feed
import Foundation

final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var presenter: Image_Feed.WebViewPresenterProtocol?
    
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func didUpdateProgressValue(_ newValue: Double) {
    
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}
