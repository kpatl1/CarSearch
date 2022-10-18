//
//  ContentView.swift
//  Project3
//
//  Created by Kishan Patel on 10/18/22.
//

import SwiftUI

struct Response: Codable {
    let Results: [Vehicle]
}

struct Vehicle: Codable {
    let Model_ID: Int
    let Model_Name: String
    let Make_Name: String
}

struct ContentView: View {
    @State private var results: [Vehicle] = []
    @State private var isLoading: Bool = false
    @State private var query: String = ""

    var body: some View {
        NavigationView {
            List {
                Section("Search") {
                    TextField("Enter a vehicle manufacturer", text: $query)
                    Button("Search", action: makeRequest)
                }

                Section("Results") {
                    if !results.isEmpty {
                        ForEach(results, id: \.Model_ID) { vehicle in
                            VStack(alignment: .leading) {
                                Text(vehicle.Make_Name).font(.headline)
                                Text(vehicle.Model_Name)
                            }
                        }
                    } else {
                        Text("Please make a request...")
                    }
                }
            }
            .navigationTitle("Car Search")
            .toolbar {
                if isLoading {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        ProgressView()
                    }
                }
            }
        }
    }

    private func makeRequest() {
        Task {
            self.isLoading = true
            await fetchCars(query: query)
            self.isLoading = false
        }
    }

    private func fetchCars(query: String) async {
        let validQuery = query.replacingOccurrences(of: " ", with: "+")
        guard let url = URL(string: "https://vpic.nhtsa.dot.gov/api/vehicles/GetModelsForMake/\(validQuery)?format=json") else {
            print("Invalid URL")
            return
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let response = try JSONDecoder().decode(Response.self, from: data)
            self.results = response.Results
        } catch {
            print("Invalid Data")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
