//
//  DataManager.swift
//  FlightInfoApp
//
//  Created by Sergey on 25.08.2021.
//

import Foundation

class DataManager {
    // MARK: - Static Properties
    static var defaultAirportIata: String? {
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
    
    static var storageAirportIata: String? {
        get {
            UserDefaults.standard.string(forKey: "StorageAirportIata")
        }
        set {
            if let airportIata = newValue {
                UserDefaults.standard.setValue(airportIata, forKey: "StorageAirportIata")
            } else {
                UserDefaults.standard.removeObject(forKey: "StorageAirportIata")
            }
        }
    }
    
    static var storageDate: Date? {
        get {
            Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "StorageDate"))
        }
        set {
            if let date = newValue {
                UserDefaults.standard.setValue(date.timeIntervalSince1970, forKey: "StorageDate")
            } else {
                UserDefaults.standard.removeObject(forKey: "StorageDate")
            }
        }
    }
    
    static var storageTimeInterval: TimeInterval {
        get {
            let interval = UserDefaults.standard.double(forKey: "storageTimeInterval")
            return interval == 0 ? 3600 : interval
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "storageTimeInterval")
        }
    }
    
    // MARK: - Initialization
    private init() {}
    
}
