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
//    let flight_date: String?
//    let flight_status: String?
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
//    let estimated_runway: String?
//    let actual_runway: String?
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
//    let estimated_runway: String?
//    let actual_runway: String?
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
//    let speed_horizontal: Float?
//    let speed_vertical: Float?
//    let is_ground: Bool?
//}

//struct CodesharedAirline: Decodable {
//    let airline_name: String?
//    let airline_iata: String?
//    let airline_icao: String?
//    let flight_number: String?
//    let flight_iata: String?
//    let flight_icao: String?
//}

enum URLS: String {
    case apiUrl = "http://api.aviationstack.com/v1/flights?access_key="
    case accessKey = "bf9f1644f60ea683c4a27c95035f65ab"
}

enum FlyghtsViewKey: String {
    case arrival = "&arr_iata="
    case diparture = "&dep_iata="
}
