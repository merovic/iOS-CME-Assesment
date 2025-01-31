//
//  APIClient.swift
//  CombineNetworking
//
//  Created by Amir Ahmed on 11/12/2023.
//

import Foundation
import Combine

class APIClient {
    private static var cancellables: Set<AnyCancellable> = []
    
    @discardableResult
    static func performDecodableRequestURLSession<T>(_ route: APIRouter) -> AnyPublisher<T, Error> where T: Decodable {
        do {
            let urlRequest = try route.asURLRequest()
            return URLSession.shared.dataTaskPublisher(for: urlRequest)
                .subscribe(on: DispatchQueue.global(qos: .background))
                .handleEvents(receiveOutput: { data, response in
                    if let responseString = String(data: data, encoding: .utf8) {
                        CustomPrint.swiftyAPIPrint(request: urlRequest, response: responseString, isDecodable: true)
                    }
                    CustomPrint.swiftyAPIPrintString(data: data)
                }, receiveCompletion: { completion in
                    switch completion {
                    case .failure(let error):
                        CustomPrint.swiftyAPIPrintError(message: error.localizedDescription)
                    case .finished:
                        print("Request finished successfully.")
                    }
                })
                .tryMap { data, response -> Data in
                    guard let httpResponse = response as? HTTPURLResponse,
                          (200...299).contains(httpResponse.statusCode) else {
                        throw APIError.invalidResponse
                    }
                    return data
                }
                .decode(type: T.self, decoder: JSONDecoder())
                .receive(on: DispatchQueue.main)
                .eraseToAnyPublisher()
        } catch {
            print("Request creation failed with error: \(error)")
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}

