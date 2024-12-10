//
//  APIService.swift
//  TestTaskIcons
//
//  Created by Konstantin on 27.11.2024.
//

import Foundation

protocol APIServiceProtocol {
    func fetchIconsData(query: String, count: Int, offset: Int, completion: @escaping (Result<Data, Error>) -> Void)
    func fetchPreviewImageData(urlString: String, completion: @escaping (Result<Data, Error>) -> Void)
    func fetchFullSizeImageData(urlString: String, completion: @escaping (Result<Data, Error>) -> Void)
    func cancelFetchingQueryData()
    func cancelFetchingImageData(urlString: String)
}

final class APIService: APIServiceProtocol {
    private let baseURL = "https://api.iconfinder.com/v4/icons/search"
    private let taskManager: TaskManagerProtocol
    private let requestBuilder: URLRequestBuilderProtocol
    
    init(taskManager: TaskManagerProtocol, requestBuilder: URLRequestBuilderProtocol) {
        self.taskManager = taskManager
        self.requestBuilder = requestBuilder
    }
    
    func fetchIconsData(query: String, count: Int, offset: Int, completion: @escaping (Result<Data, Error>) -> Void) {
        
        guard let request = requestBuilder.makeModelRequest(urlString: baseURL, query: query, count: count, offset: offset) else {
            completion(.failure(NSError(domain: "InvalidURLrequest", code: 0, userInfo: [NSLocalizedDescriptionKey: "The provided URL request is invalid"])))
            return
        }
        
        sendRequest(request, urlString: baseURL) { result in
            completion(result)
        }
    }
    
    func fetchPreviewImageData(urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        
        guard let request = requestBuilder.makeImageDataRequest(urlString: urlString, withAuth: false) else {
            completion(.failure(NSError(domain: "InvalidURLrequest", code: 0, userInfo: [NSLocalizedDescriptionKey: "The provided URL request is invalid"])))
            return
        }

        sendRequest(request, urlString: urlString) { result in
            completion(result)
        }
    }
    
    func fetchFullSizeImageData(urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let request = requestBuilder.makeImageDataRequest(urlString: urlString, withAuth: true) else {
            completion(.failure(NSError(domain: "InvalidURLrequest", code: 0, userInfo: [NSLocalizedDescriptionKey: "The provided URL request is invalid"])))
            return
        }
        
        sendRequest(request, urlString: urlString) { result in
            completion(result)
        }
    }
    
    func cancelFetchingQueryData() {
        taskManager.cancel(urlString: baseURL)
    }
    
    func cancelFetchingImageData(urlString: String) {
        taskManager.cancel(urlString: urlString)
    }
    
    private func sendRequest(_ request: URLRequest, urlString: String, completion: @escaping (Result<Data, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self else { return }
            if let error = error as NSError?, error.domain == NSURLErrorDomain, error.code == NSURLErrorCancelled {
                return
            }
            
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let data else {
                completion(.failure(NSError(domain: "NoData", code: 0, userInfo: [NSLocalizedDescriptionKey: "The response returned no data."])))
                return
            }
            taskManager.remove(urlString: urlString)
            completion(.success(data))
        }
        taskManager.add(urlString: urlString, task: task)
        task.resume()
    }
}


