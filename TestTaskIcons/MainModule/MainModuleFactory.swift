//
//  Factory.swift
//  TestTaskIcons
//
//  Created by Konstantin on 29.11.2024.
//

import Foundation

protocol MainModuleFactoryProtocol {
    func makeMainModuleViewController() -> MainModuleViewController
}

final class MainModuleFactory: MainModuleFactoryProtocol {
    
    func makeMainModuleViewController() -> MainModuleViewController {
        let taskManager = TaskManager()
        let authProvider = AuthProvider()
        let requestBuider = URLRequestBuilder(authProvider: authProvider)
        let apiService = APIService(taskManager: taskManager, requestBuilder: requestBuider)
        let databaseService = DatabaseService()
        let imageSaveService = ImageSaveService()
        let cancellableExecutor = CancellableExecutor()
        let dataProvider = DataProvider(apiService: apiService, databaseService: databaseService)
        
        let presenter = MainModulePresenter(dataProvider: dataProvider, imageSaveService: imageSaveService, cancellableExecutor: cancellableExecutor)
        let mainModuleVC = MainModuleViewController(presenter: presenter)
        presenter.view = mainModuleVC
        return mainModuleVC
    }
}
