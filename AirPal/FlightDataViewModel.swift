//
//  FileDataViewModel.swift
//  AirPal
//
//  Created by Marianna Mikhael on 4/11/24.
//

import Foundation

@MainActor
class FlightDataViewModel: ObservableObject {
    @Published var flightData: FlightData?

    
    func getFlightData(flightNumber: String) async throws {
        guard let url = Endpoint.flightNumber(flight: flightNumber).url else {
            throw NetworkError.invalidURL
        }

        if let response: Flight = try await APIClient().requestData(for: url) {
            flightData = response.data.first ?? nil
        }
    }

}
