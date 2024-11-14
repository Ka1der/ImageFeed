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
        //given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as! WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController.presenter = presenter
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testPresenterCallsLoadRequest() {
           // given
           let viewController = WebViewViewControllerSpy()
           let authHelper = AuthHelper()
           let presenter = WebViewPresenter(authHelper: authHelper)
           viewController.presenter = presenter
           presenter.view = viewController
           
           // when
           presenter.viewDidLoad()
           
           // then
           XCTAssertTrue(viewController.loadRequestCalled)
       }
    
    func testProgressVisibleWhenLessThenOne() {
        //given
        let authHelper = AuthHelper()
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        
        //when
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        //then
        XCTAssertFalse(shouldHideProgress)
    }
    
    func testProgressHiddenWhenOne() {
        // given
        let presenter = WebViewPresenter(authHelper: AuthHelper())
        
        // when
        let shouldHideProgress = presenter.shouldHideProgress(for: 1.0)
        
        // then
        XCTAssertTrue(shouldHideProgress)
    }
    
    func testAuthHelperAuthURL() {
        //given
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
        
        //when
        let url = authHelper.authURL()

        guard let urlString = url?.absoluteString else {
            XCTFail("Auth URL is nil")
            return
        }

        //then
        XCTAssertTrue(urlString.contains(configuration.authURLString))
        XCTAssertTrue(urlString.contains(configuration.accessKey))
        XCTAssertTrue(urlString.contains(configuration.redirectURI))
        XCTAssertTrue(urlString.contains("code"))
        XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
          // given
          var urlComponents = URLComponents(string: "https://unsplash.com/oauth/authorize/native")!
          urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
          let url = urlComponents.url!
          let authHelper = AuthHelper()
          
          // when
          let code = authHelper.code(from: url)
          
          // then
          XCTAssertEqual(code, "test code")
      }
}
