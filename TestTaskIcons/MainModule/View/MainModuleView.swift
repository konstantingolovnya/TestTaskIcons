//
//  MainModuleView.swift
//  TestTaskIcons
//
//  Created by Konstantin on 29.11.2024.
//

import UIKit

final class MainModuleView: UIView {
    private var icons: [MainModuleIconModel] = []
    private var presenter: MainModulePresenterProtocol
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.register(IconTableViewCell.self, forCellReuseIdentifier: String(describing: IconTableViewCell.self))
        view.backgroundColor = .systemBackground
        view.separatorStyle = .singleLine
        view.showsVerticalScrollIndicator = false
        view.dataSource = self
        view.delegate = self
        view.prefetchDataSource = self
        return view
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        return view
    }()
    
    private lazy var emptyView = EmptyView(frame: .zero)
    
    init(presenter: MainModulePresenterProtocol) {
        self.presenter = presenter
        super.init(frame: .zero)
        setupSubviews()
        setupConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(_ icons: [MainModuleIconModel]) {
        self.icons = icons
        tableView.reloadData()
        tableView.isHidden = false
        emptyView.isHidden = true
    }
    
    func addNew(_ icons: [MainModuleIconModel], at indexPaths: [IndexPath]) {
        self.icons.append(contentsOf: icons)
        
        tableView.beginUpdates()
        tableView.insertRows(at: indexPaths, with: .none)
        tableView.endUpdates()
        
        tableView.isHidden = false
        emptyView.isHidden = true
    }
    
    func startSpinner() {
        spinner.startAnimating()
    }
    
    func stopSpinner() {
        spinner.stopAnimating()
    }
    
    func showEmptyView() {
        emptyView.setMessageText("Use search to display icons")
        emptyView.isHidden = false
        tableView.isHidden = true
    }
    
    func showNotFoundView(query: String) {
        emptyView.setMessageText("Nothing found for the request \"\(query)\"")
        emptyView.isHidden = false
        tableView.isHidden = true
    }
    
    func showProcessingView(query: String) {
        emptyView.setMessageText("Searching for icons by request \"\(query)\"")
        emptyView.isHidden = false
        tableView.isHidden = true
    }
}

extension MainModuleView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let icon = icons[indexPath.row]
        let downloadURLString = icon.downloadURL
        
        presenter.saveImageToGallery(urlString: downloadURLString) { result in
            switch result {
            case .success:
                print("Image saved to gallery")
            case .failure(let error):
                print("Failed to save image: \(error.localizedDescription)")
            }
        }
    }
}

extension MainModuleView: UITableViewDataSourcePrefetching {
    
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        let rows = indexPaths.map { $0.row }
        guard let index = rows.max() else { return }
        presenter.loadMoreIcons(index: index)
    }
}

extension MainModuleView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        icons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: IconTableViewCell.self)) as? IconTableViewCell else {
            return UITableViewCell()
        }
        let icon = icons[indexPath.row]
        
        cell.configure(with: icon) { [weak self] in
            guard let self else { return }
            presenter.cancelLoadingImage(urlString: icon.previewURL)
        }
        
        presenter.loadImage(urlString: icon.previewURL) { image in
            cell.setImage(image)
        }
        
        return cell
    }
}

private extension MainModuleView {
    
    func setupSubviews() {
        addSubview(tableView)
        addSubview(spinner)
        addSubview(emptyView)
    }
    
    func setupConstrains() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = UITableView.automaticDimension
        spinner.translatesAutoresizingMaskIntoConstraints = false
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            emptyView.topAnchor.constraint(equalTo: tableView.topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: tableView.bottomAnchor),
            emptyView.leadingAnchor.constraint(equalTo: tableView.leadingAnchor),
            emptyView.trailingAnchor.constraint(equalTo: tableView.trailingAnchor)
        ])
    }
}
