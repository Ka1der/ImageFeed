//
//  WebViewViewControllerSpy.swift
//  Image FeedTests
//
//  Created by Kaider on 10.11.2024.
//

import Image_Feed
import Foundation

final class WebViewViewControllerSpy: WebViewViewControllerProtocol {
       var presenter: WebViewPresenterProtocol?
       var loadRequestCalled: Bool = false
       
       func load(request: URLRequest) {
           loadRequestCalled = true
       }
       
       func setProgressValue(_ newValue: Float) { }
       func setProgressHidden(_ isHidden: Bool) { }
   }
