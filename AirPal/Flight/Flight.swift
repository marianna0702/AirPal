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

struct FlightData: Codable {
    let flightDate: String
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
    let delay: Int?
    let scheduled: String
    let estimated: String
    let actual: String?
}

struct FlightDetails: Codable {
    let number: String
    let iata: String
    let icao: String
}
