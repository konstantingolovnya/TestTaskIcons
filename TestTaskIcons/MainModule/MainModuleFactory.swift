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
        let tasksManager = TasksManager()
        let authProvider = AuthProvider()
        let apiService = APIService(authProvider: authProvider, tasksManager: tasksManager)
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
