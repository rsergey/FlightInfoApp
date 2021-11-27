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
    
    static var storageArrivalFlights: Bool {
        get {
            UserDefaults.standard.bool(forKey: "StorageArrivalFlights")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "StorageArrivalFlights")
        }
    }
    
    static var storageDepartureFlights: Bool {
        get {
            UserDefaults.standard.bool(forKey: "StorageDepartureFlights")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "StorageDepartureFlights")
        }
    }
    
    
    static var storageArrivalDate: Date? {
        get {
            Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "StorageArrivalDate"))
        }
        set {
            if let date = newValue {
                UserDefaults.standard.setValue(date.timeIntervalSince1970, forKey: "StorageArrivalDate")
            } else {
                UserDefaults.standard.removeObject(forKey: "StorageArrivalDate")
            }
        }
    }
    
    static var storageDepartureDate: Date? {
        get {
            Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "StorageDepartureDate"))
        }
        set {
            if let date = newValue {
                UserDefaults.standard.setValue(date.timeIntervalSince1970, forKey: "StorageDepartureDate")
            } else {
                UserDefaults.standard.removeObject(forKey: "StorageDepartureDate")
            }
        }
    }
    
    static var storageTimeInterval: TimeInterval {
        get {
            let interval = UserDefaults.standard.double(forKey: "storageTimeInterval")
            return interval == 0 ? 10800 : interval
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "storageTimeInterval")
        }
    }
    
    // MARK: - Initialization
    private init() {}
    
}
