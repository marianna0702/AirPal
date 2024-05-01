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

    func sendSMS<T: Codable>(for endpoint: Endpoint) async throws -> T {
        let url = URL(string: "https://rest-ww.telesign.com/v1/messaging")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("Basic [*SOME AUTH CODE*]", forHTTPHeaderField: "Authorization")
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        let postString = "phone_number=[*PHONE NUMBER*]&message=live-from-airpal&message_type=ARN"
        request.httpBody = postString.data(using: .utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

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
}

struct Endpoint {
    let path: String
    let queryItems: [URLQueryItem]

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

    static func sendSMS(phoneNumber: String, message: String) throws -> Endpoint {
        // TODO: validate auth

        return Endpoint(
            path: "/v1/messaging",
            queryItems: [
                URLQueryItem(name: "phone_number", value: phoneNumber),
                URLQueryItem(name: "message", value: Data(message.utf8).base64EncodedString()),
                URLQueryItem(name: "message_type", value: "ARN")
            ]
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
        components.queryItems = queryItems
        return components.url
    }
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case invalidAccessKey
    case invalidFlightNumber
}


