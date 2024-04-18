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
        let endpoint = try Endpoint.flightNumber(flight: flightNumber)
        if let response: Flight = try await APIClient().requestData(for: endpoint) {
            flightData = response.data.first ?? nil
        }
    }

}
