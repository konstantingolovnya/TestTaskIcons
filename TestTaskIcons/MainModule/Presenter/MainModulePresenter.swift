//
//  Presenter.swift
//  TestTaskIcons
//
//  Created by Konstantin on 27.11.2024.
//

import Foundation
import UIKit

protocol MainModulePresenterProtocol {
    var view: MainModuleViewProtocol? { get set }
    
    func searchIcons(query: String)
    func loadImage(urlString: String, completion: @escaping (UIImage) -> Void)
    func cancelLoadingImage(urlString: String)
    func saveImageToGallery(urlString: String, completion: @escaping (Result<Void, Error>) -> Void)
    func loadMoreIcons(index: Int)
}

protocol MainModuleViewProtocol: AnyObject {
    func displayIcons(_ icons: [MainModuleIconModel])
    func startSpinner()
    func stopSpinner()
    func showError(_ error: Error)
    func showEmpty()
    func showNotFound(query: String)
    func showProcessing(query: String)
    func displayAdittionalIcons(_ icons: [MainModuleIconModel], at indexPaths: [IndexPath])
}

final class MainModulePresenter: MainModulePresenterProtocol {
    weak var view: MainModuleViewProtocol?
    private var icons: [MainModuleIconModel] = []
    
    private var currentQuery = ""
    private var totalCount = 0
    private var currentOffset = 0
    private let pageSize = 20
    
    private let dataProvider: DataProviderProtocol
    private let imageSaveService: ImageSaveServiceProtocol
    private let cancellableExecutor: CancellableExecutorProtocol
    
    init(dataProvider: DataProviderProtocol, imageSaveService: ImageSaveServiceProtocol, cancellableExecutor: CancellableExecutorProtocol) {
        self.dataProvider = dataProvider
        self.imageSaveService = imageSaveService
        self.cancellableExecutor = cancellableExecutor
    }
    
    func searchIcons(query: String) {
        cancellableExecutor.execute(delay: .seconds(1)) { [weak self] isCancelled in
            guard let self, !isCancelled else { return }
            
            resetPagination()
            
            guard !query.isEmpty else {
                dataProvider.cancelLoadingQueryData()
                view?.stopSpinner()
                view?.showEmpty()
                return
            }
            
            currentQuery = query
            
            view?.startSpinner()
            view?.showProcessing(query: query)
            
            dataProvider.loadIcons(query: query, count: pageSize, offset: currentOffset) { result in
                self.view?.stopSpinner()
                
                switch result {
                case .success(let fetchedIcons):
                    guard !fetchedIcons.icons.isEmpty else {
                        self.view?.showNotFound(query: query)
                        return
                    }
                    let icons = self.mapIcons(from: fetchedIcons.icons)
                    self.view?.displayIcons(icons)
                    self.icons = icons
                    self.totalCount = fetchedIcons.totalCount
                    self.currentOffset += self.pageSize
                case .failure(let error):
                    self.view?.showError(error)
                }
            }
        }
    }
    
    func loadImage(urlString: String, completion: @escaping (UIImage) -> Void) {
        dataProvider.loadPreviewImage(url: urlString) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let loadedImage):
                completion(loadedImage)
            case .failure(let error):
                view?.showError(error)
            }
        }
    }
    
    func cancelLoadingImage(urlString: String) {
        dataProvider.cancelLoadingImageData(id: urlString)
    }
    
    func saveImageToGallery(urlString: String, completion: @escaping (Result<Void, Error>) -> Void) {
        dataProvider.loadFullImage(url: urlString) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let loadedImage):
                imageSaveService.save(loadedImage, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func loadMoreIcons(index: Int) {
        let currenMaxIndex = icons.count - 1
        guard index >= currenMaxIndex else { return }
        
        dataProvider.loadIcons(query: currentQuery, count: pageSize, offset: currentOffset) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let fetchedIcons):
                guard !fetchedIcons.icons.isEmpty else { return }
                
                let icons = mapIcons(from: fetchedIcons.icons)
                let startIndex = self.icons.count
                self.icons.append(contentsOf: icons)
                let endIndex = self.icons.count
                currentOffset += pageSize
                let newIndexPaths = (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
                view?.displayAdittionalIcons(icons, at: newIndexPaths)
            case .failure(let error):
                view?.showError(error)
            }
        }
    }
    
    private func mapIcons(from fetchedIcons: [Icon]) -> [MainModuleIconModel] {
        return fetchedIcons.compactMap { fetchedIcon in
            guard
                let largestSize = fetchedIcon.rasterSizes.max(by: { $0.size < $1.size }),
                let format = largestSize.formats.first(where: { $0.format == "png"})
            else { return nil }
            
            let maxHeight = largestSize.sizeHeight
            let maxWidth = largestSize.sizeWidth
            
            let icon: MainModuleIconModel = MainModuleIconModel(
                previewURL: format.previewURL,
                downloadURL: format.downloadURL,
                maxWidth: maxWidth,
                maxHeight: maxHeight,
                tags: fetchedIcon.tags.prefix(10).joined(separator: ", ")
            )
            return icon
        }
    }
    
    private func resetPagination() {
        icons = []
        currentQuery = ""
        totalCount = 0
        currentOffset = 0
    }
}

