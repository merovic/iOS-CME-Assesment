//
//  CustomPrint.swift
//  CustomPrint
//
//  Created by AmirAhmed team on 02/02/2021.
//

import Foundation

struct CustomPrint {

    static func swiftyAPIPrint(request: URLRequest, response: Any, isDecodable: Bool) {
        printHeader(title: "API Request URL")
        print("📗 Request: \(request)")

        printHeader(title: "API Request Body")
        if let requestBody = request.httpBody {
            do {
                let jsonArray = try JSONSerialization.jsonObject(with: requestBody, options: [])
                print("📗 Request Body: \(jsonArray)")
            } catch {
                print("\n📕 Error parsing request body: \(error)")
            }
        } else {
            print("\n📕 No Request Body - Parameters Embedded in URL")
        }

        printFooter()
    }

    static func swiftyAPIPrintString(data: Data?) {
        printHeader(title: "API JSON Response")
        guard let jsonData = data else {
            print("\n📕 No Data")
            printFooter()
            return
        }

        do {
            let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: [])
            let prettyJsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)

            if let jsonString = String(data: prettyJsonData, encoding: .utf8) {
                print("📗 Response: \(jsonString)")
            } else {
                print("📙 Unable to convert JSON data to String")
            }
        } catch {
            print("\n📕 Error serializing JSON: \(error)")
        }

        printFooter()
    }

    static func swiftyAPIPrintError(message: String) {
        printHeader(title: "API Error Message")
        print("\n📕 Error: \(message)")
        printFooter()
    }

    // MARK: - Helper Functions

    private static func printHeader(title: String) {
        print("*\n*")
        print("***************** \(title) *****************\n*\n*")
    }

    private static func printFooter() {
        print("**********************************\n*\n*")
    }
}
