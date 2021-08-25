//
//  URL.swift
//  FlightInfoApp
//
//  Created by Sergey on 25.08.2021.
//

enum URLs: String {
    case airportsUrl = "http://api.aviationstack.com/v1/airports?access_key="
    case flightsUrl = "http://api.aviationstack.com/v1/flights?access_key="
}

enum FlyghtsViewKey: String {
    case arrival = "&arr_iata="
    case diparture = "&dep_iata="
}

enum Keys: String {
    case accessKey = "bf9f1644f60ea683c4a27c95035f65ab"
}
