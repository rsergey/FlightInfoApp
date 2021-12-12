//
//  FlightMenu.swift
//  FlightInfoApp
//
//  Created by Sergey on 11.12.2021.
//

class FlightMenu {
    var title: String
    var items: [String]
    var isHidden: Bool
    
    init(title: String, items: [String], isHidden: Bool) {
        self.title = title
        self.items = items
        self.isHidden = isHidden
    }
}
