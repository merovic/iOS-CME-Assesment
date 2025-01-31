//
//  RestCountriesViewModel.swift
//  cme-technical-assessment
//
//  Created by Amir Morsy on 31/01/2025.
//

import Foundation
import Combine
import CoreLocation
import Network

class RestCountriesViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var countries: [RESTCountry] = []
    
    @Published var selectedCountries: [RESTCountry] = []
    
    @Published var searchText = ""
    
    @Published var isLoading: Bool = false
    
    private let defaultCountry = "Russia"
    private let userDefaultsKey = "SavedCountries"
        
    let dataRepository: RestCountriesRepository
    private var locationManager: LocationManagerRepository
    
    init(dataRepository: RestCountriesRepository = APIRestCountriesRepository(),
         locationManager: LocationManagerRepository = LocationManager.shared) {
        self.dataRepository = dataRepository
        self.locationManager = locationManager
        fetchCountries()
    }
    
    func fetchCountries() {
        if NetworkManager.shared.isConnected {
            isLoading = true
            dataRepository.getAllCountries()
                .compactMap({$0})
                .sink(receiveCompletion: { (completion) in
                    switch completion {
                    case .finished:
                        print("Publisher stopped observing")
                    case .failure(let error):
                        print(error)
                    }
                }, receiveValue: {[weak self] response in
                    guard let self = self else { return }
                    defer { isLoading = false }
                    countries = response
                    fetchUserLocationCountry()
                }).store(in: &cancellables)
        } else {
            loadSelectedCountries()
        }
    }
    
    func searchCountry() {
        if let country = countries.first(where: { $0.commonName.lowercased() == searchText.lowercased() }) {
            addCountry(country)
            searchText = ""
        }
    }
    
    func addCountry(_ country: RESTCountry) {
        if selectedCountries.count < 5 && !selectedCountries.contains(where: { $0.commonName == country.commonName }) {
            selectedCountries.append(country)
            saveSelectedCountries()
        }
    }
    
    func removeCountry(at offsets: IndexSet) {
        selectedCountries.remove(atOffsets: offsets)
        saveSelectedCountries()
    }
    
    func saveSelectedCountries() {
        if let encodedData = try? JSONEncoder().encode(selectedCountries) {
            UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
        }
    }
    
    func loadSelectedCountries() {
        if let savedData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedCountries = try? JSONDecoder().decode([RESTCountry].self, from: savedData) {
            selectedCountries = decodedCountries
        }
    }
}

extension RestCountriesViewModel {
    func fetchUserLocationCountry() {
        locationManager.requestLocation { [weak self] country in
            DispatchQueue.main.async {
                if country != nil {
                    self?.addCountryToSelectedList(country: country!)
                } else {
                    self?.addDefaultCountryToSelectedList()
                }
            }
        }
    }

    private func addCountryToSelectedList(country: String) {
        if let selectedCountry = self.countries.first(where: { $0.commonName == country }) {
            self.selectedCountries.append(selectedCountry)
        } else {
            self.addDefaultCountryToSelectedList()
        }
    }

    private func addDefaultCountryToSelectedList() {
        if let defaultCountry = self.countries.first(where: { $0.commonName == self.defaultCountry }) {
            self.selectedCountries.append(defaultCountry)
        }
    }
}
