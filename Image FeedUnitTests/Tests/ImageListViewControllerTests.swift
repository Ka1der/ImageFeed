//
//  ImageListViewControllerTests.swift
//  Image FeedTests
//
//  Created by Kaider on 14.11.2024.
//

import XCTest
@testable import Image_Feed

final class ImageListViewControllerSpy_Tests: XCTestCase {
    var viewControllerSpy: ImageListViewControllerSpy!
    
    override func setUp() {
        super.setUp()
        viewControllerSpy = ImageListViewControllerSpy()
    }
    
    override func tearDown() {
        viewControllerSpy = nil
        super.tearDown()
    }
    
    func testUpdateTableViewAnimatedCalled() {
        viewControllerSpy.updateTableViewAnimated(withPhotos: [])
        XCTAssertTrue(viewControllerSpy.updateTableViewAnimatedCalled)
    }
    
    func testShowLikeErrorCalled() {
        viewControllerSpy.showLikeError()
        XCTAssertTrue(viewControllerSpy.showLikeErrorCalled)
    }
}
