//
//  DataProvider.swift
//  TestTaskIcons
//
//  Created by Konstantin on 27.11.2024.
//

import Foundation
import UIKit

protocol DataProviderProtocol {
    func loadIcons(query: String, completion: @escaping (Result<IconsResponseModel, Error>) -> Void)
    func loadPreviewImage(url: String, completion: @escaping (Result<UIImage, Error>) -> Void)
    func loadImage(url: String, completion: @escaping (Result<UIImage, Error>) -> Void)
    func cancelLoadingImage(url: String)
}

final class DataProvider: DataProviderProtocol {
    private let apiService: APIServiceProtocol
    private let databaseService: DatabaseServiceProtocol
    
    init(apiService: APIService, databaseService: DatabaseService) {
        self.apiService = apiService
        self.databaseService = databaseService
    }
    
    func loadIcons(query: String, completion: @escaping (Result<IconsResponseModel, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            
            databaseService.load(key: query) { iconsData in
                if let iconsData, let cachedIcons = try? JSONDecoder().decode(IconsResponseModel.self, from: iconsData) {
                    DispatchQueue.main.async {
                        completion(.success(cachedIcons))
                    }
                    return
                }
                
                self.apiService.fetchIconsData(query: query) { result in
                    switch result {
                    case .success(let data):
                        let decoder = JSONDecoder()
                        do {
                            let decodedResponse = try decoder.decode(IconsResponseModel.self, from: data)
                            self.databaseService.save(key: query, value: data)
                            DispatchQueue.main.async {
                                completion(.success(decodedResponse))
                            }
                        } catch {
                            DispatchQueue.main.async {
                                completion(.failure(error))
                            }
                        }
                    case .failure(let error):
                        DispatchQueue.main.async {
                            completion(.failure(error))
                        }
                    }
                }
            }
        }
    }
    
    func loadPreviewImage(url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        fetchImageData(url: url, withAuth: false, useCache: true, completion: completion)
    }
    
    func loadImage(url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        fetchImageData(url: url, withAuth: true, useCache: false, completion: completion)
    }
    
    func cancelLoadingImage(url: String) {
        apiService.cancelFetchingImageData(urlString: url)
    }
    
    private func fetchImageData(url: String, withAuth: Bool, useCache: Bool, completion: @escaping (Result<UIImage, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            
            if useCache {
                databaseService.load(key: url) { cachedData in
                    if let cachedData, let image = UIImage(data: cachedData) {
                        DispatchQueue.main.async {
                            completion(.success(image))
                        }
                        return
                    }
                }
            }
            
            apiService.fetchImageData(urlString: url, withAuth: withAuth) { result in
                switch result {
                case .success(let data):
                    guard let image = UIImage(data: data) else {
                        DispatchQueue.main.async {
                            completion(.failure(NSError(domain: "ImageProcessing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to an image."])))
                        }
                        return
                    }
                    
                    if useCache {
                        self.databaseService.save(key: url, value: data)
                    }
                    
                    DispatchQueue.main.async {
                        completion(.success(image))
                    }
                case .failure(let error):
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}
