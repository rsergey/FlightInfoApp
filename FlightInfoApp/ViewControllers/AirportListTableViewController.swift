//
//  AirportListTableViewController.swift
//  FlightInfoApp
//
//  Created by Sergey on 25.08.2021.
//

import UIKit

class AirportListTableViewController: UITableViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    private var airports: [Airports] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        fetchAirports()
        setupRefreshControl()
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
    
    private func networkFailedAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Network request failed!",
                                          message: "Please try again.",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .default)
            alert.addAction(okAction)
            self.present(alert, animated: true)
        }
    }
    
    private func stopUpdateAnimation() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            if self.refreshControl != nil {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    @objc private func fetchAirports() {
        NetworkManager.shared.fetchAirports(from: .airportsUrl,
                                            key: .accessKey) { (result) in
            switch result {
            case .success(let airports):
                self.airports = airports
                self.stopUpdateAnimation()
                self.tableView.reloadData()
            case .failure(_):
                self.stopUpdateAnimation()
                self.networkFailedAlert()
            }
        }
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl?.addTarget(self, action: #selector(fetchAirports), for: .valueChanged)
    }
}
