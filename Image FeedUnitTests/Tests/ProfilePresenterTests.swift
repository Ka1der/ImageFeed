//
//  ProfilePresenterTests.swift
//  Image FeedTests
//
//  Created by Kaider on 14.11.2024.
//

import XCTest
@testable import Image_Feed

final class ProfilePresenterTests: XCTestCase {
    var presenter: ProfilePresenterSpy!
    var viewController: ProfileViewControllerSpy!
    
    override func setUp() {
        super.setUp()
        presenter = ProfilePresenterSpy()
        viewController = ProfileViewControllerSpy()
        presenter.view = viewController
    }
    
    override func tearDown() {
        presenter = nil
        viewController = nil
        super.tearDown()
    }
    
    func testViewDidLoadCalled() {
        presenter.viewDidLoad()
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testLogoutCalled() {
        presenter.logout()
        XCTAssertTrue(presenter.logoutCalled)
    }
    
    func testPerformLogoutCalled() {
        presenter.performLogout()
        XCTAssertTrue(presenter.performLogoutCalled)
    }
    
    func testUpdateAvatarCalled() {
        presenter.updateAvatar()
        XCTAssertTrue(presenter.updateAvatarCalled)
    }
}
