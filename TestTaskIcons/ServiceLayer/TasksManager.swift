//
//  ImageLoaderService.swift
//  TestTaskIcons
//
//  Created by Konstantin on 29.11.2024.
//

import Foundation

protocol TasksManagerProtocol {
    func add(urlString: String, task: URLSessionDataTask)
    func remove(urlString: String)
    func cancel(urlString: String)
}

final class TasksManager: TasksManagerProtocol {
    private var runningRequests: [String: URLSessionDataTask] = [:]
    private let lock = NSLock()
    
    deinit {
        cancelAllTasks()
    }
    
    enum ImageLoaderServiceError: Error {
        case invalidURL
        case noData
    }
    
    func add(urlString: String, task: URLSessionDataTask) {
        lock.withLock {
            runningRequests[urlString] = task
        }
    }
    
    func remove(urlString: String) {
        lock.withLock {
            self.runningRequests[urlString] = nil
        }
    }
    
    func cancel(urlString: String) {
        lock.withLock {
            runningRequests[urlString]?.cancel()
            runningRequests[urlString] = nil
        }
    }
    
    func getRunningRequests() -> [String: URLSessionDataTask] {
        lock.lock()
        defer { lock.unlock() }

        return runningRequests
    }
    
    private func cancelAllTasks() {
        lock.withLock {
            runningRequests.forEach { (_, task) in
                task.cancel()
            }
            runningRequests.removeAll()
        }
    }
}
