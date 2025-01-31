//
//  APIRouter.swift
//  APIRouter
//
//  Created by Amir Ahmed on 11/12/2023.
//

import Foundation

enum APIRouter: URLRequestConvertible {
    
    case getAllCountries
    
    // MARK: - RequestParameterMethod
    private var requestParameter: RequestParameterMethod? {
        switch self {
        case .getAllCountries:
            return .queryParam
        }
    }
    
    // MARK: - contentType
    private var contentType: String {
        switch self {
        case .getAllCountries:
            return ContentType.json.rawValue
        }
    }
    // MARK: - HTTPMethod
    private var method: HTTPMethod {
        switch self {
        case .getAllCountries:
            return .get
        }
    }
    
    // MARK: - EndPoint
    private var endpoint: String {
        switch self {
        case .getAllCountries:
            return RemoteServers.ProductionServer.value
        }
    }
    
    // MARK: - Path
    private var path: String {
        switch self {
        case .getAllCountries:
            return "all"
        }
    }
    
    // MARK: - Parameters
    private var parameters: Parameters? {
        switch self {
        case .getAllCountries:
            return nil
        }
    }
    
    // MARK: - URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let fullURL = URL(string: endpoint)!.appendingPathComponent(path)
        var urlComponents = URLComponents(url: fullURL, resolvingAgainstBaseURL: true)
        var urlRequest = URLRequest(url: fullURL)
        
        // HTTPMethod
        urlRequest.httpMethod = method.rawValue
        
        // Headers
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.acceptType.rawValue)
        urlRequest.setValue(ContentType.json.rawValue, forHTTPHeaderField: HTTPHeaderField.contentType.rawValue)
        
        // Parameters
        switch requestParameter {
        case .queryParam:
            if let parameters = parameters {
                urlComponents?.queryItems = parameters!.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
            }
        case .pathParam:
            break
        case .formParam:
            if let parameters = parameters {
                do {
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters!, options: [])
                } catch {
                    throw error
                }
            }
        case .none:
            break
        }
        
        guard let finalURL = urlComponents?.url else {
            fatalError("Failed to construct URL with parameters")
        }
        urlRequest.url = finalURL
        
        return urlRequest
    }

}
