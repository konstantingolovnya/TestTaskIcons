//
//  DataProvider.swift
//  TestTaskIcons
//
//  Created by Konstantin on 27.11.2024.
//

import Foundation
import UIKit

protocol DataProviderProtocol {
    func loadIcons(query: String, count: Int, offset: Int, completion: @escaping (Result<IconsResponseModel, Error>) -> Void)
    func loadPreviewImage(url: String, completion: @escaping (Result<UIImage, Error>) -> Void)
    func loadFullImage(url: String, completion: @escaping (Result<UIImage, Error>) -> Void)
    func cancelLoadingImageData(id: String)
    func cancelLoadingQueryData()
}

final class DataProvider: DataProviderProtocol {
    private let apiService: APIServiceProtocol
    private let databaseService: DatabaseServiceProtocol
    
    init(apiService: APIService, databaseService: DatabaseService) {
        self.apiService = apiService
        self.databaseService = databaseService
    }
    
    func loadIcons(query: String, count: Int, offset: Int, completion: @escaping (Result<IconsResponseModel, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            
            let key = "\(query)_\(count)_\(offset)"
            
            if let iconsData = databaseService.load(key: key),
               let cachedIcons = try? JSONDecoder().decode(IconsResponseModel.self, from: iconsData) {
                DispatchQueue.main.async {
                    completion(.success(cachedIcons))
                }
                return
            }
            
            self.apiService.fetchIconsData(query: query, count: count, offset: offset) { result in
                var loadingResult: Result<IconsResponseModel, Error>
                
                switch result {
                case .success(let data):
                    let decoder = JSONDecoder()
                    do {
                        let decodedResponse = try decoder.decode(IconsResponseModel.self, from: data)
                        self.databaseService.save(key: key, value: data)
                        loadingResult = .success(decodedResponse)
                    } catch {
                        loadingResult = .failure(error)
                    }
                case .failure(let error):
                    loadingResult = .failure(error)
                }
                DispatchQueue.main.async {
                    completion(loadingResult)
                }
            }
            return
        }
    }
    
    func loadPreviewImage(url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            
            if let cachedData = databaseService.load(key: url), let image = UIImage(data: cachedData) {
                DispatchQueue.main.async {
                    completion(.success(image))
                }
                return
            }
            
            apiService.fetchPreviewImageData(urlString: url) { result in
                var loadingResult: Result<UIImage, Error>
                
                switch result {
                case .success(let data):
                    guard let image = UIImage(data: data) else {
                        loadingResult = .failure(NSError(domain: "ImageProcessing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to an image."]))
                        return
                    }
                    self.databaseService.save(key: url, value: data)
                    loadingResult = .success(image)
                case .failure(let error):
                        loadingResult = .failure(error)
                }
                DispatchQueue.main.async {
                    completion(loadingResult)
                }
            }
        }
    }
    
    func loadFullImage(url: String, completion: @escaping (Result<UIImage, Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self else { return }
            
            apiService.fetchFullSizeImageData(urlString: url) { result in
                var loadingResult: Result<UIImage, Error>
                
                switch result {
                case .success(let data):
                    guard let image = UIImage(data: data) else {
                        loadingResult = .failure(NSError(domain: "ImageProcessing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to convert data to an image."]))
                        return
                    }
                    loadingResult = .success(image)
                case .failure(let error):
                    loadingResult = .failure(error)
                }
                DispatchQueue.main.async {
                    completion(loadingResult)
                }
            }
        }
    }
    
    func cancelLoadingImageData(id: String) {
        apiService.cancelFetchingImageData(urlString: id)
    }
    
    func cancelLoadingQueryData() {
        apiService.cancelFetchingQueryData()
    }

}
