//
//  EmptyView.swift
//  TestTaskIcons
//
//  Created by Konstantin on 05.12.2024.
//

import UIKit

class EmptyView: UIView {
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Use search to display icons"
        label.textAlignment = .center
        label.textColor = .gray
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
        setupConstrains()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension EmptyView {
    func setupSubviews() {
        addSubview(messageLabel)
    }
    
    func setupConstrains() {
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}
