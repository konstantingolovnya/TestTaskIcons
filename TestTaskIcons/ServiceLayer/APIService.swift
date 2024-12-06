//
//  APIService.swift
//  TestTaskIcons
//
//  Created by Konstantin on 27.11.2024.
//

import Foundation

protocol APIServiceProtocol {
    func fetchIconsData(query: String, completion: @escaping (Result<Data, Error>) -> Void)
    func fetchImageData(urlString: String, withAuth: Bool, completion: @escaping (Result<Data, Error>) -> Void)
    func cancelFetchingImageData(urlString: String)
}

final class APIService: APIServiceProtocol {
    private let baseURL = "https://api.iconfinder.com/v4/icons/search"
    private let authProvider: AuthProviderProtocol
    private let tasksManager: TasksManagerProtocol
    
    init(authProvider: AuthProviderProtocol, tasksManager: TasksManagerProtocol) {
        self.authProvider = authProvider
        self.tasksManager = tasksManager
    }
    
    func fetchIconsData(query: String, completion: @escaping (Result<Data, Error>) -> Void) {
        
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "premium", value: "0")
        ]
        
        guard let url = urlComponents.url else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "The provided URL is invalid."])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request = authProvider.modifyRequest(request)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self else { return }
            if let error {
                completion(.failure(error))
                return
            }
            
            guard let data else {
                completion(.failure(NSError(domain: "NoData", code: 0, userInfo: [NSLocalizedDescriptionKey: "The response returned no data."])))
                return
            }
            tasksManager.remove(urlString: url.absoluteString)
            completion(.success(data))
        }
        tasksManager.add(urlString: url.absoluteString, task: task)
            task.resume()
    }
    
    func fetchImageData(urlString: String, withAuth: Bool, completion: @escaping (Result<Data, Error>) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "InvalidURL", code: 0, userInfo: [NSLocalizedDescriptionKey: "The provided URL is invalid."])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if withAuth {
            request = authProvider.modifyRequest(request)
        }
        
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
            
            tasksManager.remove(urlString: urlString)
            completion(.success(data))
        }
        
        tasksManager.add(urlString: urlString, task: task)
        task.resume()
    }
    
    func cancelFetchingImageData(urlString: String) {
        tasksManager.cancel(urlString: urlString)
    }
}


