//
//  RestCountriesRepository.swift
//  cme-technical-assessment
//
//  Created by Amir Morsy on 31/01/2025.
//

import Foundation
import Combine

protocol RestCountriesRepository {
    func getAllCountries() -> AnyPublisher<RESTCountriesAPIResponse, Error>
}

class APIRestCountriesRepository: RestCountriesRepository {
    func getAllCountries() -> AnyPublisher<RESTCountriesAPIResponse, any Error> {
        return APIClient.performDecodableRequestURLSession(APIRouter.getAllCountries)
    }
}
