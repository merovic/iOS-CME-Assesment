//
//  LoadingIndicatorView.swift
//  take-home-test-ios
//
//  Created by Amir Morsy on 06/01/2025.
//

import UIKit
import Combine

class LoadingIndicatorView: UIView {
    
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    
    @Published var isLoading: Bool = false
    
    private static var shared: LoadingIndicatorView?
    
    static func sharedInstance(in view: UIView) -> LoadingIndicatorView {
        if shared == nil {
            let indicatorView = LoadingIndicatorView(frame: CGRect.zero)
            shared = indicatorView
            indicatorView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(indicatorView)
            NSLayoutConstraint.activate([
                indicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                indicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        }
        return shared!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupActivityIndicator()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupActivityIndicator()
    }
    
    private func setupActivityIndicator() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.color = .gray
        activityIndicator.hidesWhenStopped = true
        addSubview(activityIndicator)
        
        // Automatically set up constraints
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func startAnimating() {
        self.isLoading = true
        activityIndicator.startAnimating()
    }
    
    func stopAnimating() {
        self.isLoading = false
        activityIndicator.stopAnimating()
    }
}
