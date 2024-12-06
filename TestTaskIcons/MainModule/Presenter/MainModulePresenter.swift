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
    func saveIconToGallery(urlString: String, completion: @escaping (Result<Void, Error>) -> Void)
}

protocol MainModuleViewProtocol: AnyObject {
    func displayIcons(_ icons: [MainModuleIconModel])
    func startSpinner()
    func stopSpinner()
    func showError(_ error: Error)
    func showEmpty()
}

final class MainModulePresenter: MainModulePresenterProtocol {
    weak var view: MainModuleViewProtocol?
    private var fetchedIcons: [Icon]?
    
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
            
            guard !query.isEmpty else {
                view?.showEmpty()
                return
            }
            
            view?.startSpinner()
            
            dataProvider.loadIcons(query: query) { [weak self] result in
                guard let self else { return }
                view?.stopSpinner()
                
                switch result {
                case .success(let fetchedIcons):
                    guard !fetchedIcons.icons.isEmpty else {
                        view?.showEmpty()
                        return
                    }
                    let icons = mapIcons(from: fetchedIcons.icons)
                    view?.displayIcons(icons)
                    self.fetchedIcons = fetchedIcons.icons
                case .failure(let error):
                    view?.showError(error)
                }
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
        dataProvider.cancelLoadingImage(url: urlString)
    }
    
    func saveIconToGallery(urlString: String, completion: @escaping (Result<Void, Error>) -> Void) {
        dataProvider.loadImage(url: urlString) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let loadedImage):
                imageSaveService.save(loadedImage, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
