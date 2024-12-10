//
//  ViewController.swift
//  TestTaskIcons
//
//  Created by Konstantin on 27.11.2024.
//

import UIKit

class MainModuleViewController: UIViewController {
    var presenter: MainModulePresenterProtocol
    private lazy var mainModuleView = MainModuleView(presenter: presenter)
    
    private lazy var searchBar: UISearchBar = {
        let view = UISearchBar()
        view.placeholder = "Search icons"
        view.delegate = self
        view.accessibilityIdentifier = "SearchBar"
        return view
    }()
    
    init(presenter: MainModulePresenterProtocol) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = mainModuleView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        mainModuleView.showEmptyView()
        view.backgroundColor = .systemBackground
    }
    
    private func setupNavigationBar() {
        navigationItem.titleView = searchBar
    }
}

extension MainModuleViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let query = searchBar.text else { return }
        presenter.searchIcons(query: query)
    }
}

extension MainModuleViewController: MainModuleViewProtocol {
    func showEmpty() {
        print("Show empty view")
        mainModuleView.showEmptyView()
    }
    
    func displayIcons(_ icons: [MainModuleIconModel]) {
        mainModuleView.update(icons)
    }
    
    func displayAdittionalIcons(_ icons: [MainModuleIconModel]) {
        mainModuleView.addNew(icons)
    }
    
    func startSpinner() {
        mainModuleView.startSpinner()
    }
    
    func stopSpinner() {
        mainModuleView.stopSpinner()
    }
    
    func showError(_ error: any Error) {
        print("Show error")
        print(error.localizedDescription)
    }
    
    func showNotFound(query: String) {
        mainModuleView.showNotFoundView(query: query)
    }
    
    func showProcessing(query: String) {
        mainModuleView.showProcessingView(query: query)
    }
}
