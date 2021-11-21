//
//  DataManager.swift
//  FlightInfoApp
//
//  Created by Sergey on 25.08.2021.
//

import Foundation

class DataManager {
    // MARK: - Static Properties
    static var defaultAirportIata: String! {
        get {
            UserDefaults.standard.string(forKey: "DefaultAirportIata")
        }
        set {
            if let airportIata = newValue {
                UserDefaults.standard.setValue(airportIata, forKey: "DefaultAirportIata")
            } else {
                UserDefaults.standard.removeObject(forKey: "DefaultAirportIata")
            }
        }
    }
    
    // MARK: - Initialization
    private init() {}
    
}
