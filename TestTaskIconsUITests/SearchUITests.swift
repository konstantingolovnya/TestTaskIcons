//
//  SearchUITests.swift
//  TestTaskIconsUITests
//
//  Created by Konstantin on 05.12.2024.
//

import XCTest
@testable import TestTaskIcons


final class SearchUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launchArguments.append("--UITest")
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
        try super.tearDownWithError()
    }
    
    func testSearchBarExists() throws {
        let searchBar = app.searchFields["SearchBar"]
            XCTAssertTrue(searchBar.exists)
        }
    
    

    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
