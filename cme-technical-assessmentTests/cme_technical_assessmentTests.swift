//
//  cme_technical_assessmentTests.swift
//  cme-technical-assessmentTests
//
//  Created by Amir Morsy on 31/01/2025.
//

import Foundation
import XCTest
import Combine
@testable import cme_technical_assessment

class DummyRestCountriesRepository: RestCountriesRepository {
    var response: RESTCountriesAPIResponse?
    var error: Error?
    
    func getAllCountries() -> AnyPublisher<cme_technical_assessment.RESTCountriesAPIResponse, any Error> {
        if let error = error {
            return Fail(error: error).eraseToAnyPublisher()
        } else if let response = response {
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
    }
}

class DummyLocationManager: LocationManagerRepository {
    var dummyCountry: String?
    
    func requestLocation(completion: @escaping (String?) -> Void) {
        completion(dummyCountry)
    }
}


class RestCountriesViewModelTests: XCTestCase {
    
    var viewModel: RestCountriesViewModel!
    var dummyRepository: DummyRestCountriesRepository!
    var cancellables: Set<AnyCancellable>!
    
    var dummyLocationManager: DummyLocationManager!
    
    override func setUp() {
        super.setUp()
        cancellables = []
        
        dummyRepository = DummyRestCountriesRepository()
        dummyRepository.response = [
            RESTCountry(
                name: Name(common: "Egypt", official: "Arab Republic of Egypt"),
                currencies: ["EGP": Currency(name: "Egyptian Pound", symbol: "£")],
                capital: ["Cairo"]
            ),
            RESTCountry(
                name: Name(common: "Germany", official: "Federal Republic of Germany"),
                currencies: ["EUR": Currency(name: "Euro", symbol: "€")],
                capital: ["Berlin"]
            ),
            RESTCountry(
                name: Name(common: "Japan", official: "Japan"),
                currencies: ["JPY": Currency(name: "Japanese Yen", symbol: "¥")],
                capital: ["Tokyo"]
            ),
            RESTCountry(
                name: Name(common: "United States", official: "United States of America"),
                currencies: ["USD": Currency(name: "United States Dollar", symbol: "$")],
                capital: ["Washington, D.C."]
            ),
            RESTCountry(
                name: Name(common: "France", official: "French Republic"),
                currencies: ["EUR": Currency(name: "Euro", symbol: "€")],
                capital: ["Paris"]
            )
        ]
        
        dummyLocationManager = DummyLocationManager()
        dummyLocationManager.dummyCountry = "Canada"
        
        viewModel = RestCountriesViewModel(dataRepository: dummyRepository,
                                           locationManager: dummyLocationManager)
        
        UserDefaults.standard.removeObject(forKey: "SavedCountries")
    }
    
    override func tearDown() {
        viewModel = nil
        dummyRepository = nil
        cancellables = nil
        dummyLocationManager = nil
        super.tearDown()
    }
    
    // MARK: - Test searchCountry()
    
    func testSearchCountryAddsCountryWhenFound() {
        // Given: The list of all countries already fetched (via dummyRepository).
        // Ensure that "USA" is among the available countries.
        XCTAssertTrue(viewModel.countries.contains { $0.commonName == "USA" })
        
        // When: The user types "usa" (case-insensitive) in the search field and taps search.
        viewModel.searchText = "usa"
        viewModel.searchCountry()
        
        // Then: "USA" should be added to selectedCountries.
        XCTAssertTrue(viewModel.selectedCountries.contains { $0.commonName == "USA" })
        // And the search text is cleared.
        XCTAssertEqual(viewModel.searchText, "")
    }
    
    func testSearchCountryDoesNothingWhenNotFound() {
        // Given: A search text that does not match any country.
        viewModel.searchText = "NonExistentCountry"
        
        // When: searchCountry() is called.
        viewModel.searchCountry()
        
        // Then: selectedCountries remains empty (apart from the country added by location logic).
        // Note: Since fetchCountries() is called during init and our dummy location manager returns "Canada",
        // "Canada" may already have been added. So we ensure that no new country was added.
        let countBefore = viewModel.selectedCountries.count
        viewModel.searchCountry()
        let countAfter = viewModel.selectedCountries.count
        XCTAssertEqual(countBefore, countAfter)
    }
    
    // MARK: - Test addCountry limit and duplicate prevention
    
    func testAddCountryPreventsDuplicatesAndRespectsLimit() {
        // When: We add five distinct countries.
        let countriesToAdd = ["USA", "Canada", "Russia", "Germany", "France"]
        for name in countriesToAdd {
            if let country = viewModel.countries.first(where: { $0.commonName == name }) {
                viewModel.addCountry(country)
            }
        }
        
        // Then: The selectedCountries should contain at most 5 items.
        XCTAssertLessThanOrEqual(viewModel.selectedCountries.count, 5)
        
        // And adding a duplicate should not increase the count.
        let initialCount = viewModel.selectedCountries.count
        if let duplicate = viewModel.countries.first(where: { $0.commonName == "USA" }) {
            viewModel.addCountry(duplicate)
        }
        XCTAssertEqual(viewModel.selectedCountries.count, initialCount)
        
        // And trying to add an extra country (if not already added) should not work.
        // For example, if we attempt to add "Canada" (assuming it exists) when there are already 5.
        let italy = RESTCountry(
            name: Name(common: "Italy", official: "Italian Republic"),
            currencies: ["EUR": Currency(name: "Euro", symbol: "€")],
            capital: ["Roma"]
        )
        viewModel.addCountry(italy)
        XCTAssertEqual(viewModel.selectedCountries.count, initialCount)
    }
    
    // MARK: - Test removeCountry(at:)
    
    func testRemoveCountry() {
        // Given: Add two countries.
        if let country1 = viewModel.countries.first(where: { $0.commonName == "USA" }) {
            viewModel.addCountry(country1)
        }
        if let country2 = viewModel.countries.first(where: { $0.commonName == "Canada" }) {
            viewModel.addCountry(country2)
        }
        
        XCTAssertEqual(viewModel.selectedCountries.count, 2)
        
        // When: Remove the first country.
        viewModel.removeCountry(at: IndexSet(integer: 0))
        
        // Then: Only one country should remain and it should be "Canada".
        XCTAssertEqual(viewModel.selectedCountries.count, 1)
        XCTAssertEqual(viewModel.selectedCountries.first?.commonName, "Canada")
    }
    
    // MARK: - Test fetchCountries() with location handling
    
    func testFetchCountriesAddsLocationCountry() {
        // Because fetchCountries() is called on initialization, and our dummy location manager returns "Canada",
        // we expect that after fetching, selectedCountries will contain that country.
        
        // We wait for the asynchronous fetch to complete.
        let expectation = XCTestExpectation(description: "Fetch countries and add location country")
        
        // Because fetchCountries uses Combine, delay checking for a short time.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            // Check that the countries were fetched.
            XCTAssertFalse(self.viewModel.countries.isEmpty)
            
            // Check that "Canada" was added based on the dummy location.
            XCTAssertTrue(self.viewModel.selectedCountries.contains { $0.commonName == "Canada" })
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    // MARK: - Test persistence with UserDefaults
    
    func testSavingAndLoadingSelectedCountries() {
        // Given: Clear any saved data.
        UserDefaults.standard.removeObject(forKey: "SavedCountries")
        
        // When: We add a country and then simulate a new instance loading from UserDefaults.
        if let country = viewModel.countries.first(where: { $0.commonName == "USA" }) {
            viewModel.addCountry(country)
        }
        
        // Force saving by calling saveSelectedCountries (normally called inside addCountry).
        // Then create a new view model that will load from UserDefaults when network is disconnected.
        // (Simulate network disconnected.)
        // For this test, we assume that if network is disconnected, loadSelectedCountries() is used.
        // For example, you might temporarily override NetworkManager.shared.isConnected.
        // Here we just call the load method directly on a new instance.
        
        let newViewModel = RestCountriesViewModel(dataRepository: dummyRepository, locationManager: dummyLocationManager)
        // Simulate offline by not calling fetchCountries() but rather loadSelectedCountries():
        newViewModel.loadSelectedCountries()
        
        // Then: The new view model's selectedCountries should include "USA".
        XCTAssertTrue(newViewModel.selectedCountries.contains { $0.commonName == "USA" })
    }
}
