//
//  MainModulePresenterTests.swift
//  TestTaskIconsTests
//
//  Created by Konstantin on 04.12.2024.
//

import XCTest
import UIKit
@testable import TestTaskIcons

final class MainModulePresenterTests: XCTestCase {
    
    class MockMainModuleView: MainModuleViewProtocol {
        var displayedIcons: [MainModuleIconModel] = []
        var spinnerStarted = false
        var spinnerStopped = false
        var shownError: Error?
        var shownEmpty = false
        
        func displayIcons(_ icons: [MainModuleIconModel]) {
            displayedIcons = icons
        }
        
        func startSpinner() {
            spinnerStarted = true
        }
        
        func stopSpinner() {
            spinnerStopped = true
        }
        
        func showError(_ error: Error) {
            shownError = error
        }
        
        func showEmpty() {
            shownEmpty = true
        }
    }

    class MockDataProvider: DataProviderProtocol {
        var iconsResult: Result<IconsResponseModel, Error>?
        var previewImageResult: Result<UIImage, Error>?
        var imageResult: Result<UIImage, Error>?
        var cancelledURLs: [String] = []
        
        func loadIcons(query: String, completion: @escaping (Result<IconsResponseModel, Error>) -> Void) {
            if let result = iconsResult {
                completion(result)
            }
        }
        
        func loadPreviewImage(url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
            if let result = previewImageResult {
                completion(result)
            }
        }
        
        func loadImage(url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
            if let result = imageResult {
                completion(result)
            }
        }
        
        func cancelLoadingImage(url: String) {
            cancelledURLs.append(url)
        }
    }

    class MockImageSaveService: ImageSaveServiceProtocol {
        var saveImageResult: Result<Void, Error>?
        
        func save(_ image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
            if let result = saveImageResult {
                completion(result)
            }
        }
    }
    
    class MockCancellableExecutor: CancellableExecutorProtocol {
        var executeStatusResult: Bool? = false
        
        func execute(delay: DispatchTimeInterval, cancelationStatusHandler: @escaping (Bool) -> ()) {
            if let result = executeStatusResult {
                cancelationStatusHandler(result)
            }
        }
    }

    private var mockView: MockMainModuleView?
    private var mockDataProvider: MockDataProvider?
    private var presenter: MainModulePresenter?
    private var mockImageSaveService: MockImageSaveService?
    private var mockCancellableExecutor: MockCancellableExecutor?
    
    override func setUpWithError() throws {
        mockView = MockMainModuleView()
        mockDataProvider = MockDataProvider()
        mockImageSaveService = MockImageSaveService()
        mockCancellableExecutor = MockCancellableExecutor()
        presenter = MainModulePresenter(dataProvider: mockDataProvider!, imageSaveService: mockImageSaveService!, cancellableExecutor: mockCancellableExecutor!)
        presenter?.view = mockView
    }

    override func tearDownWithError() throws {
        mockView = nil
        mockDataProvider = nil
        mockImageSaveService = nil
        mockCancellableExecutor = nil
        presenter = nil
    }
    
    func testSearchIconsDisplaysIconsOnSuccess() throws {
        let mockIcons = IconsResponseModel(icons: [
            Icon(iconID: 123, tags: ["example"], rasterSizes: [RasterSize(size: 10, sizeWidth: 10, sizeHeight: 10, formats: [IconFormat(format: "png", previewURL: "https://example.com/1", downloadURL: "https://example.com/2")])])
        ])
        mockDataProvider!.iconsResult = .success(mockIcons)
        
        presenter!.searchIcons(query: "example")
        
        XCTAssertTrue(mockView!.spinnerStarted)
        XCTAssertTrue(mockView!.spinnerStopped)
        XCTAssertFalse(mockView!.shownEmpty)
        XCTAssertNil(mockView!.shownError)
        XCTAssertEqual(mockView!.displayedIcons.count, 1)
    }
    
    func testSearchIconsShowsEmptyWhenNoIcons() {
        let mockIcons = IconsResponseModel(icons: [])
        mockDataProvider!.iconsResult = .success(mockIcons)

        presenter!.searchIcons(query: "example")

        XCTAssertTrue(mockView!.spinnerStarted)
        XCTAssertTrue(mockView!.spinnerStopped)
        XCTAssertTrue(mockView!.shownEmpty)
        XCTAssertNil(mockView!.shownError)
        XCTAssertEqual(mockView!.displayedIcons.count, 0)
    }
    
    func testLoadImageCallsCompletionOnSuccess() {
        let mockPreviewURL = "https://example.com/1"
        
        let testImage = UIImage()
        mockDataProvider!.previewImageResult = .success(testImage)

        let expectation = XCTestExpectation(description: "Image loaded")
        presenter!.loadImage(urlString: mockPreviewURL) { image in
            XCTAssertEqual(image, testImage)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 1.0)
    }
    
    func testLoadImageShowsErrorOnFailure() {
        let mockPreviewURL = "https://example.com/1"
        mockDataProvider!.previewImageResult = .failure(NSError(domain: "TestError", code: 1))

        presenter!.loadImage(urlString: mockPreviewURL) { _ in
            XCTFail()
        }

        XCTAssertNotNil(mockView!.shownError)
    }
    
    func testCancelLoadingImageCorrectURL() {
        let mockPreviewURL = "https://example.com/1"
        
        presenter!.cancelLoadingImage(urlString: mockPreviewURL)

        XCTAssertEqual(mockDataProvider!.cancelledURLs.count, 1)
    }
    
    func testSaveIconToGalleryCompletionOnSuccess() {
        let testImage = UIImage()
        mockDataProvider!.imageResult = .success(testImage)
        
        mockImageSaveService?.saveImageResult = .success(())
        let mockDownloadURL = "https://example.com/2"
        
        let expectation = XCTestExpectation(description: "Image saved")

            self.presenter!.saveIconToGallery(urlString: mockDownloadURL) { result in
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure:
                    XCTFail()
                }
            }

        wait(for: [expectation], timeout: 1)
    }

    func testSaveIconToGalleryFailsOnInvalidIndex() {
        let mockDownloadURL = "999"
        mockDataProvider!.imageResult = .failure(NSError(domain: "InvalidURL", code: 1))
        
        let expectation = XCTestExpectation(description: "Save failed")
        presenter!.saveIconToGallery(urlString: mockDownloadURL) { result in
            switch result {
            case .success:
                XCTFail()
            case .failure(let error):
                XCTAssertEqual((error as NSError).domain, "InvalidURL")
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 1.0)
    }
}

