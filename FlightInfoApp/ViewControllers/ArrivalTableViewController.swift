//
//  ArrivalTableViewController.swift
//  FlightInfoApp
//
//  Created by Sergey on 07.08.2021.
//

import UIKit

class ArrivalTableViewController: UITableViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Public Properties
    var airportIata = ""
    
    // MARK: - Private Properties
    private let searchController = UISearchController(searchResultsController: nil)
    private var arrivalFlights: [Flights] = []
    private var filteredFlights: [Flights] = []
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.navigationItem.title = "Actual flights to " + airportIata

        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        setupRefreshControl()
        fecthArrivalFlights()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search flight"
        tabBarController?.navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredFlights.count
        }
        return arrivalFlights.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "arrivalFlightCell", for: indexPath)
        var arrivalFlight: Flights
        if isFiltering {
            arrivalFlight = filteredFlights[indexPath.row]
        } else {
            arrivalFlight = arrivalFlights[indexPath.row]
        }
        var content = cell.defaultContentConfiguration()
        content.text = prepareDataForText(arrivalFlight: arrivalFlight)
        content.secondaryText = prepareDataForSecondaryText(arrivalFlight: arrivalFlight)
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Private Methods
    private func prepareDataForText(arrivalFlight: Flights) -> String {
        var time = ""
        let flightIata = arrivalFlight.flight?.iata ?? ""
        let departureAirport = arrivalFlight.departure?.airport ?? "unknown airport"
        let departureAirportIata = arrivalFlight.departure?.iata ?? ""
        
        if let arrivalTime = arrivalFlight.arrival?.scheduled {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            let stopTime = dateFormatter.date(from: arrivalTime)
            dateFormatter.dateFormat = "dd-MM-yyy HH:mm:ss"
            time += " ↘︎ " + dateFormatter.string(from: stopTime ?? Date())
        }
        
        return time + "\t ✈︎ " + flightIata + "\n" + departureAirport + " (" + departureAirportIata + ")"
    }
    
    private func prepareDataForSecondaryText(arrivalFlight: Flights) -> String {
        guard var airline = arrivalFlight.airline?.name else { return "" }
        if airline == "empty" {
            airline = "private flight"
        }
        return airline
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
    
    @objc private func fecthArrivalFlights() {
        NetworkManager.shared.fetchFlights(from: .flightsUrl,
                                           key: .accessKey,
                                           type: .arrival,
                                           iata: airportIata) { result in
            switch result {
            case .success(let flights):
                self.arrivalFlights = flights
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
        refreshControl?.addTarget(self, action: #selector(fecthArrivalFlights), for: .valueChanged)
    }
}

// MARK: - Extensions
extension ArrivalTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterFlights(searchController.searchBar.text ?? "")
    }
    
    private func filterFlights(_ searchText: String) {
        filteredFlights = arrivalFlights.filter({ (flight: Flights) -> Bool in
            return (flight.departure?.airport?.lowercased().contains(searchText.lowercased()) ?? false)
        })
        tableView.reloadData()
    }
}
