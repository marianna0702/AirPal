//
//  APIClient.swift
//  AirPal
//
//  Created by Marianna Mikhael on 4/11/24.
//

import Foundation

struct APIClient {
    func requestData<T: Codable>(for url: URL) async throws -> T {
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

    var url: URL? {
        var components = URLComponents()
        components.scheme = "http"
        components.host = "api.aviationstack.com"
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
}


