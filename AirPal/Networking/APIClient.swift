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

enum Endpoints {
    static let baseURL = "http://api.aviationstack.com/v1/flights?"
    static let accessKey = KEY // TODO: store this in a proper way

    
    case flightNumber(flight: String)

    var urlString: String {
        switch self {
        case .flightNumber(let flight):
            let str  = "\(Endpoints.baseURL)flight_iata=\(flight)&\(Endpoints.accessKey)"
            return str
        }
    }

    var url: URL? {
        switch self {
        case .flightNumber(_):
            return URL(string: urlString)
        }
    }

}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
