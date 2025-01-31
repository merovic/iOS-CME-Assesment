//
//  SwiftUIKit.swift
//  take-home-test-ios
//
//  Created by Amir Morsy on 06/01/2025.
//

import Foundation
import UIKit
import SwiftUI

class ViewFragmentation {
    
    static func addSubview(subView:UIView, toView parentView:UIView) {
        parentView.addSubview(subView)
        var viewBindingsDict = [String: AnyObject]()
        viewBindingsDict["subView"] = subView
        subView.translatesAutoresizingMaskIntoConstraints = false
        subView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[subView]|", options: [], metrics: nil, views: viewBindingsDict))
        parentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[subView]|", options: [], metrics: nil, views: viewBindingsDict))
    }
    
    static func embedSwiftUIView<Content: View>(view: Content, parent: UIViewController) -> UIView {
            let newViewController = UIHostingController(rootView: view)
            newViewController.view.backgroundColor = UIColor.white
            newViewController.view.translatesAutoresizingMaskIntoConstraints = false
            parent.addChild(newViewController)
            addSubview(subView: newViewController.view, toView: parent.view)
            newViewController.didMove(toParent: parent)
            
            return newViewController.view
        }
}

extension UIView{
    func embedSwiftUIView(view: any View, parent: UIViewController){
        let newViewController = UIHostingController(rootView: AnyView(view))
        newViewController.view.backgroundColor = UIColor.clear
        newViewController.view.translatesAutoresizingMaskIntoConstraints = false
        parent.addChild(newViewController)
        ViewFragmentation.addSubview(subView: newViewController.view, toView: self)
    }
}
