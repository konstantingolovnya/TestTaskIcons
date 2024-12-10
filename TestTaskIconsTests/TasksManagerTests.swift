//
//  TasksManagerTests.swift
//  TestTaskIconsTests
//
//  Created by Konstantin on 04.12.2024.
//

import XCTest
@testable import TestTaskIcons

final class TasksManagerTests: XCTestCase {
    private var tasksManager: TaskManager!
    private var mockTask: MockURLSessionDataTask!
    
    override func setUpWithError() throws {
        tasksManager = TaskManager()
        mockTask = MockURLSessionDataTask()
    }

    override func tearDownWithError() throws {
        tasksManager = nil
        mockTask = nil
    }

    func testAddTask() {
        let urlString = "https://example.com"
        
        tasksManager.add(urlString: urlString, task: mockTask)
        
        XCTAssertNotNil(tasksManager.getRunningRequests()[urlString])
    }

    func testRemoveTask() throws {
        let urlString = "https://example.com"
        
        tasksManager.add(urlString: urlString, task: mockTask)
        tasksManager.remove(urlString: urlString)
        
        XCTAssertNil(tasksManager.getRunningRequests()[urlString])
    }
    
    func testCancelTask() throws {
        let urlString = "https://example.com"
        
        tasksManager.add(urlString: urlString, task: mockTask)
        tasksManager.cancel(urlString: urlString)
        
        XCTAssertTrue(mockTask.isCancelled)
        XCTAssertNil(tasksManager.getRunningRequests()[urlString])
    }
    
    func testCancelAllTasks() {
            let urlString1 = "https://example.com/1"
            let urlString2 = "https://example.com/2"
            let mockTask2 = MockURLSessionDataTask()
            
            tasksManager.add(urlString: urlString1, task: mockTask)
            tasksManager.add(urlString: urlString2, task: mockTask2)
            
            tasksManager = nil
            
            XCTAssertTrue(mockTask.isCancelled)
            XCTAssertTrue(mockTask2.isCancelled)
        }

}

final class MockURLSessionDataTask: URLSessionDataTask {
    private(set) var isCancelled = false

    override func cancel() {
        isCancelled = true
    }
}
