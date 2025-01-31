//
//  LocationManager.swift
//  cme-technical-assessment
//
//  Created by Amir Morsy on 31/01/2025.
//

import Foundation
import CoreLocation

import CoreLocation
import SwiftUI

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject {
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    
    @Published var currentCountry: String?
    private var geocoder = CLGeocoder()
    private var countryCompletionHandler: ((String?) -> Void)?
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
    }
    
    func requestLocation(completion: @escaping (String?) -> Void) {
        self.countryCompletionHandler = completion
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            if let country = placemarks?.first?.country {
                self?.currentCountry = country
                self?.countryCompletionHandler?(country)
            } else {
                self?.countryCompletionHandler?(nil)
            }
            
            self?.locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get user's location: \(error.localizedDescription)")
        countryCompletionHandler?(nil)
        locationManager.stopUpdatingLocation()
    }
}

