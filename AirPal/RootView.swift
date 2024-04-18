//
//  RootView.swift
//  AirPal
//
//  Created by Marianna Mikhael on 4/9/24.
//

import SwiftUI

struct RootView: View {
    @State var flightInput = ""
    @ObservedObject private var viewModel = FlightDataViewModel()

    var body: some View {
        VStack {
            Image(systemName: "airplane.departure")
                .imageScale(.large)
                .foregroundStyle(.secondary)
            TextField("Flight number", text: $flightInput)
                .textFieldStyle(.roundedBorder)
            Text("Flight: \(viewModel.flightData?.flight.iata ?? "N/A")")
                .font(.title2)
            HStack {
                Text(viewModel.flightData?.departure.iata ?? "Dep")
                Image(systemName: "arrow.left.arrow.right")
                Text(viewModel.flightData?.arrival.iata ?? "Ari")
            }
            Text("Flight Status: \(viewModel.flightData?.flightStatus ?? "N/A")")
        }
        .padding()
        .onSubmit(of: .text) {
            Task {
                do {
                    try await viewModel.getFlightData(flightNumber: flightInput.uppercased())
                } catch {
                    print("Error getting flight data", error)
                }
            }
        }
    }
}

#Preview {
    RootView()
}
