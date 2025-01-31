//
//  RestCountriesView.swift
//  cme-technical-assessment
//
//  Created by Amir Morsy on 31/01/2025.
//

import UIKit
import Combine
import SwiftUI

class RestCountriesView: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.embedSwiftUIView(view: CountryListSwiftUIView(), parent: self)
    }
}
