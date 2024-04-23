//
//  Flight.swift
//  AirPal
//
//  Created by Marianna Mikhael on 4/11/24.
//

import Foundation

struct Flight: Codable {
    let data: [FlightData]
}

struct FlightData: Codable, Equatable {
    static func == (lhs: FlightData, rhs: FlightData) -> Bool {
        // converting to string to compare easily
        // this compares each of the properties,
        // we might want to only check certain ones in the future
        return String(describing: lhs) == String(describing: rhs)
    }

    let flightDate: String
    // TODO: create enum for the possible cases -> https://rb.gy/gd2x7h
    let flightStatus: String
    let departure: FlightArrivalDeparture
    let arrival: FlightArrivalDeparture
    let flight: FlightDetails
}

struct FlightArrivalDeparture: Codable {
    let airport: String
    let timezone: String
    let iata: String
    let terminal: String?
    let gate: String?
    let delay: Int? // Delay in minutes
    let scheduled: String
    let estimated: String
    let actual: String?
}

struct FlightDetails: Codable {
    let number: String
    let iata: String
    let icao: String
}
