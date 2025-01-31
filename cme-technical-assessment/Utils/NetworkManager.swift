//
//  NetworkManager.swift
//  cme-technical-assessment
//
//  Created by Amir Morsy on 31/01/2025.
//

import Foundation
import Network

class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitor")
    
    @Published var isConnected: Bool = true
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}
