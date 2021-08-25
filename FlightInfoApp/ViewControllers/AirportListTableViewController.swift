//
//  AirportListTableViewController.swift
//  FlightInfoApp
//
//  Created by Sergey on 25.08.2021.
//

import UIKit

class AirportListTableViewController: UITableViewController {
    // MARK: - IBOutlets
    
    // MARK: - Private Properties
    private var airports: [Airports] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAirports()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        airports.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "selectionAirportCell", for: indexPath)
        let airport = airports[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = prepareDataForText(airport: airport)
        content.secondaryText = prepareDataForSecondaryText(airport: airport)
        cell.contentConfiguration = content
        return cell
    }

    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - IBAction
    @IBAction func refreshAirportList(_ sender: UIBarButtonItem) {
        fetchAirports()
    }
    
    // MARK: - Private Methods
    private func prepareDataForText(airport: Airports) -> String {
        var text = " → " + (airport.airportName ?? "-")
        text += " (" + (airport.iataCode ?? "-") + ")"
        return text
    }
    
    private func prepareDataForSecondaryText(airport: Airports) -> String {
        (airport.countryName ?? "-") + " (city iata: " + (airport.cityIataCode ?? "-") + ")"
    }
    
    private func fetchAirports() {
        NetworkManager.shared.fetchAirports(from: .airportsUrl,
                                            key: .accessKey) { (result) in
            switch result {
            case .success(let airports):
                self.airports = airports
                self.tableView.reloadData()
            case .failure(_):
                print("networkfail airports")
            }
        }
    }
}
