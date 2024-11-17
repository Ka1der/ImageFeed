//
//  Image_FeedTests.swift
//  Image FeedTests
//
//  Created by Kaider on 10.11.2024.
//

import XCTest
@testable import Image_Feed

final class WebViewTests: XCTestCase {
    
    // MARK: - Тест для проверки вызова viewDidLoad
    
    func testViewControllerCallsViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
           let viewController = WebViewViewControllerSpy()
           let authHelper = AuthHelper()
           let presenter = WebViewPresenter(authHelper: authHelper)
           viewController.presenter = presenter
           presenter.view = viewController
           
           presenter.viewDidLoad()
           
           XCTAssertTrue(viewController.loadRequestCalled)
       }
    
    func testProgressVisibleWhenLessThenOne() {
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        
        let shouldHideProgress = presenter.shouldHideProgress(for: 1.0)
        
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        let url = authHelper.authURL()

        guard let urlString = url?.absoluteString else {
            XCTFail("Auth URL is nil")
            return
        }

        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
          var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
          urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
          let url = urlComponents.url!
          let authHelper = AuthHelper()
          
          let code = authHelper.code(from: url)
          
          XCTAssertEqual(code, "test code")
      }
}
