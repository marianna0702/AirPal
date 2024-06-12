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
    @State var flightChanged = false

    var body: some View {
        VStack {
            Image(systemName: "airplane.departure")
                .imageScale(.large)
                .foregroundStyle(.secondary)
            TextField("Flight number", text: $flightInput)
                .textFieldStyle(.roundedBorder)
            Text("Flight: \(viewModel.flightCode)")
                .font(.title2)
            HStack {
                Text(viewModel.flightData?.departure.iata ?? "Dep")
                Image(systemName: "arrow.left.arrow.right")
                Text(viewModel.flightData?.arrival.iata ?? "Ari")
            }
            Text("Flight Status: \(viewModel.flightData?.flightStatus ?? "N/A")")
            Button("Refresh") {
                Task {
                    do {
                        flightChanged = try await viewModel.refreshFlightData()
                        // add tag at beginning of text
                        var text = 
                        viewModel.messages.insert("AirPal: Flight \(viewModel.flightCode)", at: 0)
                        try await APIClient().sendSMS(to: "18438551417", message: viewModel.messages.joined(separator: "\n"))
                    } catch {
                        print("Error refreshing", error)
                    }
                }
            }
            if flightChanged {
                VStack(alignment: .center) {
                    ForEach(viewModel.messages, id: \.self) {
                        Text($0)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .onSubmit(of: .text) {
            Task {
                do {
                    viewModel.flightData =  try await viewModel.getFlightData(flightNumber: flightInput.uppercased())
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
