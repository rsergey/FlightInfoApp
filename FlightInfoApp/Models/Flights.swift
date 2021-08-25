//
//  ResponseFlights.swift
//  FlightInfoApp
//
//  Created by Sergey on 08.08.2021.
//

struct ResponseFlights: Decodable {
//    let pagination: PaginationFlights?
    let data: [Flights]?
}

//struct PaginationFlights: Decodable {
//    let limit: Int?
//    let offset: Int?
//    let count: Int?
//    let total: Int?
//}

struct Flights: Decodable {
//    let flightDate: String?
//    let flightStatus: String?
    let departure: DepartureAirport?
    let arrival: ArrivalAirport?
    let airline: Airline?
    let flight: Flight?
//    let aircraft: Aircraft?
//    let live: Live?
}

struct DepartureAirport: Decodable {
    let airport: String?
//    let timezone: String?
    let iata: String?
//    let icao: String?
//    let terminal: String?
//    let gate: String?
//    let delay: Int?
    let scheduled: String?
//    let estimated: String?
//    let actual: String?
//    let estimatedRunway: String?
//    let actualRunway: String?
}

struct ArrivalAirport: Decodable {
    let airport: String?
//    let timezone: String?
    let iata: String?
//    let icao: String?
//    let terminal: String?
//    let gate: String?
//    let baggage: String?
//    let delay:Int?
    let scheduled: String?
//    let estimated: String?
//    let actual: String?
//    let estimatedRunway: String?
//    let actualRunway: String?
}

struct Airline: Decodable {
    let name: String?
//    let iata: String?
//    let icao: String?
}

struct Flight: Decodable {
//    let number: String?
    let iata: String?
//    let icao: String?
//    let codeshared: CodesharedAirline?
}

//struct Aircraft: Decodable {
//    let registration: String?
//    let iata: String?
//    let icao: String?
//    let icao24: String?
//}

//struct Live: Decodable {
//    let updated: String?
//    let latitude: Float?
//    let longitude: Float?
//    let altitude: Float?
//    let direction: Float?
//    let speedHorizontal: Float?
//    let speedVertical: Float?
//    let isGround: Bool?
//}

//struct CodesharedAirline: Decodable {
//    let airlineName: String?
//    let airlineIata: String?
//    let airlineIcao: String?
//    let flightNumber: String?
//    let flightIata: String?
//    let flightIcao: String?
//}
