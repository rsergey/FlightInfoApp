//
//  Attributes.swift
//  FlightInfoApp
//
//  Created by Sergey on 25.08.2021.
//

enum URLs: String {
    case airportsUrl = "http://api.aviationstack.com/v1/airports?access_key="
    case flightsUrl = "http://api.aviationstack.com/v1/flights?access_key="
}

enum FlightsViewKey: String {
    case arrival = "&arr_iata="
    case diparture = "&dep_iata="
}

enum FlightType: String {
    case arrival
    case departure
}

enum kSecAttributes: String {
    case service = "flightInfoAppService"
    case account = "userAccount"
}
