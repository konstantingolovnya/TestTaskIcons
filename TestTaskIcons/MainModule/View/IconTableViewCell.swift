//
//  IconTableViewCell.swift
//  TestTaskIcons
//
//  Created by Konstantin on 30.11.2024.
//

import UIKit

final class IconTableViewCell: UITableViewCell {
    private var onReuse: (() -> Void)?
    
    private lazy var iconImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.layer.cornerRadius = 8
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.numberOfLines = 1
        return label
    }()
    
    private lazy var tagsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var labelsStack: UIStackView = {
        let view = UIStackView()
        view.axis = .vertical
        view.distribution = .fillEqually
        view.spacing = 4
        view.alignment = .leading
        return view
    }()
    
    private lazy var stack: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.distribution = .fill
        view.spacing = 10
        view.alignment = .center
        return view
    }()
    
    private lazy var spinner: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.hidesWhenStopped = true
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
        setupConstrains()
        spinner.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        labelsStack.addArrangedSubview(titleLabel)
        labelsStack.addArrangedSubview(tagsLabel)
        stack.addArrangedSubview(iconImageView)
        stack.addArrangedSubview(labelsStack)
        contentView.addSubview(stack)
        contentView.addSubview(spinner)
    }
    
    private func setupConstrains() {
        stack.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        labelsStack.translatesAutoresizingMaskIntoConstraints = false
        spinner.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 60),
            iconImageView.heightAnchor.constraint(equalToConstant: 60),
            
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            spinner.centerXAnchor.constraint(equalTo: iconImageView.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: iconImageView.centerYAnchor)
        ])
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        onReuse?()
    }
    
    func configure(with model: MainModuleIconModel, onReuse: @escaping () -> Void) {
        titleLabel.text = "\(model.maxWidth) x \(model.maxHeight)"
        tagsLabel.text = model.tags
        self.onReuse = onReuse
        spinner.startAnimating()
    }
    
    func setImage(_ image: UIImage) {
        spinner.stopAnimating()
        iconImageView.image = image
    }
}
