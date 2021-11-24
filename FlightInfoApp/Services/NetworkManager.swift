//
//  NetworkManager.swift
//  FlightInfoApp
//
//  Created by Sergey on 10.08.2021.
//

import Foundation

class NetworkManager {
    // MARK: - Static Properties
    static let shared = NetworkManager()
    
    // MARK: - Initialization
    private init() {}
    
    func fetchFlights(from url: URLs, key: Keys, type: FlightsViewKey, iata: String, with complition: @escaping (Result<[Flights], Error>) -> Void) {
        let urlAdress = url.rawValue + key.rawValue + type.rawValue + iata
        guard let url = URL(string: urlAdress) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                complition(.failure(error))
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let flight = try decoder.decode(ResponseFlights.self, from: data)
                guard var flights = flight.data else { return }
                flights.sort { $0.arrival?.scheduled ?? "" < $1.arrival?.scheduled ?? "" }
                
                DispatchQueue.main.async {
                    complition(.success(flights))
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    func fetchAirports(from url: URLs, key: Keys, with complition: @escaping (Result<[Airports], Error>) -> Void) {
        let urlAdress = url.rawValue + key.rawValue
        guard let url = URL(string: urlAdress) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                complition(.failure(error))
                print(error.localizedDescription)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let airport = try decoder.decode(ResponseAirports.self, from: data)
                guard let airports = airport.data else { return }
                
                DispatchQueue.main.async {
                    complition(.success(airports))
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }.resume()
    }
}
