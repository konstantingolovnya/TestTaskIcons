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
    
    func modifyRequest(_ request: URLRequest) -> URLRequest {
        authKey = getAuthToken()
        guard let authKey else { return request }
        
        var modifiedRequest = request
        modifiedRequest.setValue("Bearer \(authKey)", forHTTPHeaderField: "Authorization")
        modifiedRequest.setValue("application/json", forHTTPHeaderField: "accept")
        return modifiedRequest
    }
    
    func getAuthToken() -> String? {
        return "yD3H3pbRbXPPvGOEUWaeDAgT2FRJLEsIQUxusgeGltDuP3PvWoLZGVF9VuVjR85p"
    }
}
