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
    private var presenter: MainModulePresenter!
    private var mockView: MockMainModuleView!
    private var mockDataProvider: MockDataProvider!
    private var mockImageSaveService: MockImageSaveService!
    private var mockCancellableExecutor: MockCancellableExecutor!

    override func setUp() {
        super.setUp()
        mockView = MockMainModuleView()
        mockDataProvider = MockDataProvider()
        mockImageSaveService = MockImageSaveService()
        mockCancellableExecutor = MockCancellableExecutor()

        presenter = MainModulePresenter(dataProvider: mockDataProvider, imageSaveService: mockImageSaveService, cancellableExecutor: mockCancellableExecutor)
        presenter.view = mockView
    }

    override func tearDown() {
        presenter = nil
        mockView = nil
        mockDataProvider = nil
        mockImageSaveService = nil
        mockCancellableExecutor = nil
        super.tearDown()
    }

    func testSearchIconsSuccess() {
        let icons = [Icon(iconID: 1, tags: ["test"], rasterSizes: [RasterSize(size: 1, sizeWidth: 1, sizeHeight: 1, formats: [IconFormat(format: "png", previewURL: "testUrl", downloadURL: "testUrl/2")])])]
        mockDataProvider.mockResult = .success(IconsResponseModel(totalCount: 1, icons: icons))

        presenter.searchIcons(query: "test")

        XCTAssertTrue(mockView.startSpinnerCalled)
        XCTAssertTrue(mockView.stopSpinnerCalled)
        XCTAssertEqual(mockView.icons.count, 1)
        XCTAssertEqual(mockView.icons.first?.tags, "test")
    }

    func testSearchIconsEmptyQuery() {
        presenter.searchIcons(query: "")

        XCTAssertTrue(mockView.showEmptyCalled)
        XCTAssertTrue(mockView.stopSpinnerCalled)
    }

    func testSearchIconsFailure() {
        let mockError = NSError(domain: "test", code: 0, userInfo: nil)
        mockDataProvider.mockResult = .failure(mockError)

        presenter.searchIcons(query: "test")

        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.error as NSError?, mockError)
    }

    func testLoadImageSuccess() {
        let expectedImage = UIImage()
        mockDataProvider.mockImageResult = .success(expectedImage)
        var returnedImage: UIImage?

        presenter.loadImage(urlString: "testUrl") { image in
            returnedImage = image
        }

        XCTAssertEqual(returnedImage, expectedImage)
    }

    func testLoadImageFailure() {
        let mockError = NSError(domain: "test", code: 0, userInfo: nil)
        mockDataProvider.mockImageResult = .failure(mockError)

        presenter.loadImage(urlString: "testUrl") { _ in }

        XCTAssertTrue(mockView.showErrorCalled)
        XCTAssertEqual(mockView.error as NSError?, mockError)
    }

    func testLoadMoreIconsSuccess() {
        let icons = [Icon(iconID: 1, tags: ["test"], rasterSizes: [RasterSize(size: 1, sizeWidth: 1, sizeHeight: 1, formats: [IconFormat(format: "png", previewURL: "testUrl", downloadURL: "testUrl/2")])])]
        
        mockDataProvider.mockResult = .success(IconsResponseModel(totalCount: 1, icons: icons))

        presenter.loadMoreIcons(index: 1)

        XCTAssertEqual(mockView.additionalIcons.count, 1)
        XCTAssertEqual(mockView.insertedIndexPaths.count, 1)
    }
    
    func testSaveImageToGallerySuccess() {
        mockDataProvider.mockImageResult = .success(UIImage())
        var saveResult: Result<Void, Error>?

        presenter.saveImageToGallery(urlString: "testUrl") { result in
            saveResult = result
        }

        XCTAssertNotNil(saveResult)
        XCTAssertTrue(mockImageSaveService.saveCalled)
    }
}

final class MockMainModuleView: MainModuleViewProtocol {
    
    var startSpinnerCalled = false
    var stopSpinnerCalled = false
    var showEmptyCalled = false
    var showErrorCalled = false
    var insertedIndexPaths: [IndexPath] = []

    var icons: [MainModuleIconModel] = []
    var additionalIcons: [MainModuleIconModel] = []
    var error: Error?

    func displayIcons(_ icons: [MainModuleIconModel]) {
        self.icons = icons
    }

    func startSpinner() {
        startSpinnerCalled = true
    }

    func stopSpinner() {
        stopSpinnerCalled = true
    }

    func showError(_ error: Error) {
        showErrorCalled = true
        self.error = error
    }

    func showEmpty() {
        showEmptyCalled = true
    }

    func showNotFound(query: String) { }

    func showProcessing(query: String) { }
    
    func displayAdittionalIcons(_ icons: [MainModuleIconModel], at indexPaths: [IndexPath]) {
            additionalIcons.append(contentsOf: icons)
            insertedIndexPaths.append(contentsOf: indexPaths)
        }
}

final class MockDataProvider: DataProviderProtocol {
    var mockResult: Result<IconsResponseModel, Error>?
    var mockImageResult: Result<UIImage, Error>?

    func loadIcons(query: String, count: Int, offset: Int, completion: @escaping (Result<IconsResponseModel, Error>) -> Void) {
        if let mockResult = mockResult {
            completion(mockResult)
        }
    }

    func loadPreviewImage(url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let mockImageResult = mockImageResult {
            completion(mockImageResult)
        }
    }

    func loadFullImage(url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        if let mockImageResult = mockImageResult {
            completion(mockImageResult)
        }
    }

    func cancelLoadingImageData(id: String) {}

    func cancelLoadingQueryData() {}
}

final class MockImageSaveService: ImageSaveServiceProtocol {
    var saveCalled = false

    func save(_ image: UIImage, completion: @escaping (Result<Void, Error>) -> Void) {
        saveCalled = true
        completion(.success(()))
    }
}

final class MockCancellableExecutor: CancellableExecutorProtocol {
    func execute(delay: DispatchTimeInterval, cancelationStatusHandler: @escaping (Bool) -> Void) {
        cancelationStatusHandler(false)
    }
}
