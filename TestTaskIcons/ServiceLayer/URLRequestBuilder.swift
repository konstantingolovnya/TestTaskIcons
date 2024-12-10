//
//  RequestBuilder.swift
//  TestTaskIcons
//
//  Created by Konstantin on 09.12.2024.
//

import Foundation

protocol URLRequestBuilderProtocol {
    func makeModelRequest(urlString: String, query: String, count: Int, offset: Int) -> URLRequest?
    func makeImageDataRequest(urlString: String, withAuth: Bool) -> URLRequest?
}

final class URLRequestBuilder: URLRequestBuilderProtocol {
    private let authProvider: AuthProviderProtocol
    
    init(authProvider: AuthProviderProtocol) {
        self.authProvider = authProvider
    }
    
    func makeModelRequest(urlString: String, query: String, count: Int, offset: Int) -> URLRequest? {
        var urlComponents = URLComponents(string: urlString)
        
        urlComponents?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "premium", value: "0"),
            URLQueryItem(name: "count", value: "\(count)"),
            URLQueryItem(name: "offset", value: "\(offset)")
        ]
        
        guard let url = urlComponents?.url else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request = authProvider.modifyRequest(request)
        
        return request
    }
    
    func makeImageDataRequest(urlString: String, withAuth: Bool) -> URLRequest? {
        guard let url = URL(string: urlString) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if withAuth {
            request = authProvider.modifyRequest(request)
        }
        
        return request
    }
}
