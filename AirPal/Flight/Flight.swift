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
    let flightDate: String
    // TODO: create enum for the possible cases -> https://rb.gy/gd2x7h
    let flightStatus: String
    let departure: FlightArrivalDeparture
    let arrival: FlightArrivalDeparture
    let flight: FlightDetails
}

struct FlightArrivalDeparture: Codable, Equatable {
    typealias Minutes = Int

    let airport: String
    let timezone: String
    let iata: String
    let terminal: String?
    let gate: String?
    let delay: Minutes?
    let scheduled: String
    let estimated: String
    let actual: String?
}

struct FlightDetails: Codable, Equatable {
    let number: String
    let iata: String
    let icao: String
}
