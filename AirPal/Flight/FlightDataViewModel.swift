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
    @Published var messages: [String] = []

    var flightCode: String {
        return flightData?.flight.iata ?? ""
    }

    func getFlightData(flightNumber: String) async throws -> FlightData? {
        let endpoint = try Endpoint.flightNumber(flight: flightNumber)
        if let response: Flight = try await APIClient().requestData(for: endpoint) {
            return response.data.first ?? nil
        }
        return nil
    }

    /// Returns true if the flight data has changed
    func refreshFlightData() async throws -> Bool {
        // clear previous changes messages
        messages = []
        guard let flightNumber = flightData?.flight.iata else {
            throw NetworkError.invalidFlightNumber
        }

        if let newFlight = try await getFlightData(flightNumber: flightNumber) {
            checkForFlightUpdates(for: newFlight)
            let hasChanged = newFlight != flightData
            flightData = newFlight
            return hasChanged
        }
        return false
    }

    func checkForFlightUpdates(for updatedFlight: FlightData) {
        // TODO: There is probably a better way of writing this code to avoid repetition
        if updatedFlight.flightStatus != flightData?.flightStatus {
            messages.append("Flight status has changed from \(flightData?.flightStatus ?? "N/A") to \(updatedFlight.flightStatus)!")
        }
        if updatedFlight.departure.terminal != flightData?.departure.terminal {
            messages.append("Departure terminal has changed from \(flightData?.departure.terminal ?? "N/A") to \(updatedFlight.departure.terminal ?? "N/A")!")
        }
        if updatedFlight.departure.gate != flightData?.departure.gate {
            messages.append("Departure gate has changed from \(flightData?.departure.gate ?? "N/A") to \(updatedFlight.departure.gate ?? "N/A")!")
        }
        if updatedFlight.departure.scheduled != flightData?.departure.scheduled {
            messages.append("Departure scheduled time has changed from \(flightData?.departure.scheduled ?? "N/A") to \(updatedFlight.departure.scheduled)!")
        }
        if updatedFlight.departure.estimated != flightData?.departure.estimated {
            messages.append("Departure estimated time has changed from \(flightData?.departure.estimated ?? "N/A") to \(updatedFlight.departure.estimated)!")
        }
        if updatedFlight.arrival.terminal != flightData?.arrival.terminal {
            messages.append("Arrival terminal has changed from \(flightData?.arrival.terminal ?? "N/A") to \(updatedFlight.arrival.terminal ?? "N/A")!")
        }
        if updatedFlight.arrival.gate != flightData?.arrival.gate {
            messages.append("Arrival gate has changed from \(flightData?.arrival.gate ?? "N/A") to \(updatedFlight.arrival.gate ?? "N/A")!")
        }
        if updatedFlight.arrival.scheduled != flightData?.arrival.scheduled {
            messages.append("Arrival scheduled time has changed from \(flightData?.arrival.scheduled ?? "N/A") to \(updatedFlight.arrival.scheduled)!")
        }
        if updatedFlight.arrival.estimated != flightData?.arrival.estimated {
            messages.append("Arrival estimated time has changed from \(flightData?.arrival.estimated ?? "N/A") to \(updatedFlight.arrival.estimated)!")
        }

    }

}
