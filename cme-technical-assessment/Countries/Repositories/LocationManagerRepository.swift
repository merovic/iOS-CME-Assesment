//
//  LocationManagerRepository.swift
//  cme-technical-assessment
//
//  Created by Amir Morsy on 31/01/2025.
//

protocol LocationManagerRepository {
    func requestLocation(completion: @escaping (String?) -> Void)
}

extension LocationManager: LocationManagerRepository {}
