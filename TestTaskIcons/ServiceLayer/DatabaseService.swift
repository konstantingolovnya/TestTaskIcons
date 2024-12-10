//
//  DatabaseService.swift
//  TestTaskIcons
//
//  Created by Konstantin on 27.11.2024.
//

import Foundation

protocol DatabaseServiceProtocol {
    func save(key: String, value: Data)
    func load(key: String) -> Data?
    func delete(key: String)
}

final class DatabaseService: DatabaseServiceProtocol {
    private let cache = NSCache<NSString, NSData>()
    
    init() {
        cache.countLimit = 500
    }
    
    func save(key: String, value: Data) {
        cache.setObject(value as NSData, forKey: key as NSString)
    }
    
    func load(key: String) -> Data? {
        cache.object(forKey: key as NSString) as Data?
    }
    
    func delete(key: String) {
        cache.removeObject(forKey: key as NSString)
    }
}

