//
//  ImageListTests.swift
//  Image FeedTests
//
//  Created by Kaider on 14.11.2024.
//

import XCTest
@testable import Image_Feed

final class ImageListPresenterTests: XCTestCase {
    var presenter: ImageListPresenterSpy!
    var viewController: ImageListViewControllerSpy!
    
    override func setUp() {
        super.setUp()
        presenter = ImageListPresenterSpy()
        viewController = ImageListViewControllerSpy()
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
    
    func testFetchPhotosNextPageCalled() {
        presenter.fetchPhotosNextPage()
        XCTAssertTrue(presenter.fetchPhotosNextPageCalled)
    }
    
    func testChangeLikeCalled() {
        presenter.changeLike(photoId: "test", isLike: true) { _ in }
        XCTAssertTrue(presenter.changeLikeCalled)
    }
}
