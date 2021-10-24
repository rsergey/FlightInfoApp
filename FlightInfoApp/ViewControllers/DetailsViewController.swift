//
//  DetailsViewController.swift
//  FlightInfoApp
//
//  Created by Sergey on 23.10.2021.
//

import UIKit

class DetailsViewController: UIViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var airportsStackView: UIStackView!
    
    @IBOutlet weak var departureAirportIataLabel: UILabel!
    @IBOutlet weak var departureAirportLabel: UILabel!
    @IBOutlet weak var departureTimelabel: UILabel!
    
    @IBOutlet weak var arrivalAirportIataLabel: UILabel!
    @IBOutlet weak var arrivalAirportLabel: UILabel!
    @IBOutlet weak var arrivalTimeLabel: UILabel!
    
    // MARK: - Public Properties
    var flight: Flights!
    
    // MARK: - Override methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setLabelsInfo()
        airportsStackView.layer.cornerRadius = 10
    }
    
    // MARK: - Private Methods
    private func setLabelsInfo() {
        departureAirportIataLabel.text = flight.departure?.iata ?? ""
        departureAirportLabel.text = flight.departure?.airport ?? ""
        
        arrivalAirportIataLabel.text = flight.arrival?.iata ?? ""
        arrivalAirportLabel.text = flight.arrival?.airport ?? ""
    }

}
