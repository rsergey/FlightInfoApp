//
//  NetworkManager.swift
//  FlightInfoApp
//
//  Created by Sergey on 10.08.2021.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fecthFlights(from url: String, key: String, type: FlyghtsViewKey, iata: String, with complition: @escaping ([Flights]) -> Void) {
        let urlAdress = url + key + type.rawValue + iata
        guard let url = URL(string: urlAdress) else { return }
        
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            if let error = error {
                print(error)
                return
            }
            
            guard let data = data else { return }
            
            do {
                let flight = try JSONDecoder().decode(ResponseFlights.self, from: data)
                guard var flights = flight.data else { return }
                flights.sort { $0.arrival?.scheduled ?? "" < $1.arrival?.scheduled ?? "" }
                
                DispatchQueue.main.async {
                    complition(flights)
//                    self.activityIndicator.stopAnimating()
//                    self.tableView.reloadData()
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }.resume()
    }
    
    
}

