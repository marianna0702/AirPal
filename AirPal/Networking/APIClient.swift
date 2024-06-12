//
//  APIClient.swift
//  AirPal
//
//  Created by Marianna Mikhael on 4/11/24.
//

import Foundation

struct APIClient {
    func requestData<T: Codable>(for endpoint: Endpoint) async throws -> T {
        guard let url = endpoint.aviationStackURL else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await URLSession.shared.data(from: url)

        guard 
            let response = response as? HTTPURLResponse,
                response.statusCode == 200
        else {
            throw NetworkError.invalidResponse
        }

        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.invalidData
        }
    }
    
    /// phoneNumber - include country code, no special characters and spaces
    /// message - Limit to 1600 characters
    func sendSMS(to phoneNumber: String, message: String) async throws {
        guard let url = Endpoint.getSMSEndpoint().teleSignURL else {
            throw NetworkError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
//        request.allHTTPHeaderFields = [
//          "Accept": "application/json",
//          "Content-Type": c, // TODO: figure out authorization
//          "Authorization": "Basic RTk3RTY4NzktOTVBNy00OTQ1LThCRDgtMEY1NzFFQTMzNTJBOlRiS0ROVVBpeUcvcjFkQ2FFVENxNDZjNVMxS3I4OEVLVDBzaHJIUmNCWjNxb01sUFJaMG9VaDM3VTVqQkhnNmZ0cUprc3J6cXRPZkh1dXhZOUxXbENnPT0="
//        ]
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        guard let customerID = Bundle.main.object(forInfoDictionaryKey: "TELESIGN_CUSTOMER_ID") as? String,
              let apiKey = Bundle.main.object(forInfoDictionaryKey: "TELESIGN_API_KEY") as? String
        else {
            throw NetworkError.invalidTelesignAuth
        }

        let authData = "\(customerID):\(apiKey)".data(using: .utf8)
        guard let encoded = authData?.base64EncodedData(),
              let decoded = String(data: encoded, encoding: .utf8) else {
            throw NetworkError.invalidTelesignAuth
        }
        request.setValue("Basic \(decoded)", forHTTPHeaderField: "Authorization")
        let postString = "phone_number=\(phoneNumber)&message=\(message)&message_type=ARN"
        request.httpBody = postString.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard
            let response = response as? HTTPURLResponse,
                response.statusCode == 200
        else {
            throw NetworkError.textFailed
        }
    }
}

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]?

    static func flightNumber(flight: String) throws -> Endpoint {
        guard let accessKey = Bundle.main.object(forInfoDictionaryKey: "AVIATIONSTACK_API_KEY") as? String else {
            throw NetworkError.invalidAccessKey
        }

        return Endpoint(
            path: "/v1/flights",
            queryItems: [
                URLQueryItem(name: "flight_iata", value: flight),
                URLQueryItem(name: "access_key", value: accessKey)
            ]
        )
    }

    static func getSMSEndpoint() -> Endpoint {
        return Endpoint(
            path: "/v1/messaging",
            queryItems: nil
        )
    }

    var aviationStackURL: URL? {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "api.aviationstack.com"
        components.path = path
        components.queryItems = queryItems
        return components.url
    }

    var teleSignURL: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "rest-ww.telesign.com"
        components.path = path
        return components.url
    }
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case invalidAccessKey
    case invalidFlightNumber
    case invalidTelesignAuth
    case textFailed
}


