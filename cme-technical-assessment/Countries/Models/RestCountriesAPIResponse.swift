//
//  RestCountriesAPIResponse.swift
//  cme-technical-assessment
//
//  Created by Amir Morsy on 31/01/2025.
//

import Foundation

// MARK: - RESTCountriesAPIResponse
struct RESTCountry: Codable, Identifiable {
    var id = UUID()
    let name: Name
    let currencies: [String: Currency]?
    let capital: [String]?
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case currencies = "currencies"
        case capital = "capital"
    }
    
    var capitalName: String {
        capital?.first ?? "Unknown"
    }
    
    var currencyName: String {
        currencies?.values.first?.name ?? "Unknown"
    }
    
    var commonName: String {
        name.common
    }
}

// MARK: - Currency
struct Currency: Codable {
    let name, symbol: String
}

// MARK: - Name
struct Name: Codable {
    let common, official: String
}

typealias RESTCountriesAPIResponse = [RESTCountry]
