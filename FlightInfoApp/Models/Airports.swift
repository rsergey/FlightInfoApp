//
//  Airports.swift
//  FlightInfoApp
//
//  Created by Sergey on 25.08.2021.
//

struct ResponseAirports: Decodable {
//    let pagination: PaginationAirports?
    let data: [Airports]?
}

//struct PaginationAirports: Decodable {
//    let offset: Int?
//    let limit: Int?
//    let count: Int?
//    let total: Int?
//}

struct Airports: Decodable {
    let id: String?
//    let gmt: String?
//    let airportId: String?
    let iataCode: String?
    let cityIataCode: String?
//    let icaoCode: String?
//    let countryIso2: String?
//    let geonameId: String?
    let latitude: String?
    let longitude: String?
    let airportName: String?
    let countryName: String?
//    let phoneNumber: String?
//    let timezone: String?
}
