//
//  CountryListSwiftUIView.swift
//  cme-technical-assessment
//
//  Created by Amir Morsy on 31/01/2025.
//

import Combine
import SwiftUI

// MARK: - Main View
struct CountryListSwiftUIView: View {
    @StateObject var viewModel = RestCountriesViewModel()

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("Enter country name", text: $viewModel.searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    
                    Button("Search") {
                        viewModel.searchCountry()
                    }
                    .padding()
                }
                
                if viewModel.isLoading {
                    LoadingView()
                } else {
                    List {
                        ForEach(viewModel.selectedCountries) { country in
                            NavigationLink(destination: CountryDetailView(country: country)) {
                                Text(country.commonName)
                            }
                        }
                        .onDelete(perform: viewModel.removeCountry)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Country List")
        }
    }
}

// MARK: - LoadingView
struct LoadingView: View {
    var body: some View {
        VStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(1.5)
                .padding()
            Text("Loading countries...")
                .font(.headline)
                .foregroundColor(.gray)
        }
    }
}
