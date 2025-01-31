//
//  CountryDetailView.swift
//  cme-technical-assessment
//
//  Created by Amir Morsy on 31/01/2025.
//

import SwiftUI

// MARK: - Detail View
struct CountryDetailView: View {
    let country: RESTCountry

    var body: some View {
        VStack(spacing: 20) {
            Text("Country: \(country.commonName)")
                .font(.title2)
                .bold()
            Text("Capital: \(country.capitalName)")
                .font(.title3)
            Text("Currency: \(country.currencyName)")
                .font(.title3)
        }
        .padding()
        .navigationTitle(country.commonName)
    }
}
