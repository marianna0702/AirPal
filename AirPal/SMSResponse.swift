//
//  SMSResponse.swift
//  AirPal
//
//  Created by Marianna Mikhael on 5/1/24.
//

import Foundation

struct SMSResponse: Codable {
    let referenceID: String
    let externalID: String?
    let status: SMSStatus
}

struct SMSStatus: Codable {
    let code: Int
    let description: String
}
