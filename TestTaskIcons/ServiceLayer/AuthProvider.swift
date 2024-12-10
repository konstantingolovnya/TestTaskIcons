//
//  AuthProvider.swift
//  TestTaskIcons
//
//  Created by Konstantin on 04.12.2024.
//

import Foundation

protocol AuthProviderProtocol {
    func modifyRequest(_ request: URLRequest) -> URLRequest
}

final class AuthProvider: AuthProviderProtocol {
    private var authKey: String?
    
    init() {
        authKey = getAuthToken()
    }
    
    func modifyRequest(_ request: URLRequest) -> URLRequest {
        guard let authKey else { return request }
        
        var modifiedRequest = request
        modifiedRequest.setValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
        modifiedRequest.setValue("application/json", forHTTPHeaderField: "accept")
        return modifiedRequest
    }
    
    private func getAuthToken() -> String? {
        return "yD3H3pbRbXPPvGOEUWaeDAgT2FRJLEsIQUxusgeGltDuP3PvWoLZGVF9VuVjR85p"
    }
}
