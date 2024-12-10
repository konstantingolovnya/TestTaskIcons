//
//  ImageLoaderService.swift
//  TestTaskIcons
//
//  Created by Konstantin on 29.11.2024.
//

import Foundation

protocol TaskManagerProtocol {
    func add(urlString: String, task: URLSessionDataTask)
    func remove(urlString: String)
    func cancel(urlString: String)
}

final class TaskManager: TaskManagerProtocol {
    private var runningTasks: [String: URLSessionDataTask] = [:]
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
            runningTasks[urlString] = task
        }
    }
    
    func remove(urlString: String) {
        lock.withLock {
            self.runningTasks[urlString] = nil
        }
    }
    
    func cancel(urlString: String) {
        lock.withLock {
            runningTasks[urlString]?.cancel()
            runningTasks[urlString] = nil
        }
    }
    
    func getRunningRequests() -> [String: URLSessionDataTask] {
        lock.lock()
        defer { lock.unlock() }

        return runningTasks
    }
    
    private func cancelAllTasks() {
        lock.withLock {
            runningTasks.forEach { (_, task) in
                task.cancel()
            }
            runningTasks.removeAll()
        }
    }
}
