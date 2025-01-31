//
//  Helpers.swift
//  CombineNetworking
//
//  Created by Amir Ahmed on 11/12/2023.
//

import Foundation

enum HTTPHeaderField: String {
    case authentication = "Authorization"
    case contentType = "Content-Type"
    case acceptType = "Accept"
    case acceptEncoding = "Accept-Encoding"
}

enum ContentType: String {
    case json = "application/json"
}

enum RequestParameterMethod: String {
    case pathParam   = "pathParam"
    case queryParam  = "queryParam"
    case formParam   = "formParam"
}

public extension Encodable {
    var dictionary: [String: Any]? {
        guard let data = try? JSONEncoder().encode(self) else {
            return nil
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap {
            $0 as? [String: Any]
        }
    }
}

protocol URLRequestConvertible {
    func asURLRequest() throws -> URLRequest
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

enum APIError: Error {
    case invalidResponse
    case invalidData
}

public typealias Parameters = [String: Any]?
