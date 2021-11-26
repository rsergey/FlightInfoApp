//
//  DepartureTableViewController.swift
//  FlightInfoApp
//
//  Created by Sergey on 07.08.2021.
//

import UIKit

class DepartureTableViewController: UITableViewController {
    // MARK: - IBOutlets
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Public Properties
    var airportIata = ""
    
    // MARK: - Private Properties
    private let searchController = UISearchController(searchResultsController: nil)
    private var departureFlights: [Flights] = []
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

        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        setupRefreshControl()
        getDepartureFlights()
        
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
        return departureFlights.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "departureFlightCell", for: indexPath)
        var departureFlight: Flights
        if isFiltering {
            departureFlight = filteredFlights[indexPath.row]
        } else {
            departureFlight = departureFlights[indexPath.row]
        }
        var content = cell.defaultContentConfiguration()
        content.text = prepareDataForText(departureFlight: departureFlight)
        content.secondaryText = prepareDataForSecondaryText(departureFlight: departureFlight)
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let flight: Flights
            
            if isFiltering {
                flight = filteredFlights[indexPath.row]
            } else {
                flight = departureFlights[indexPath.row]
            }
            
            guard let detailsVC = segue.destination as? DetailsViewController else { return }
            detailsVC.flight = flight
        }
    }
    
    // MARK: - Private Methods
    
    // Interface
    private func prepareDataForText(departureFlight: Flights) -> String {
        var time = ""
        let flightIata = departureFlight.flight?.iata ?? ""
        let arrivalAirport = departureFlight.arrival?.airport ?? "unknown airport"
        let arrivalAirportIata = departureFlight.arrival?.iata ?? ""
        
        if let departuteTime = departureFlight.departure?.scheduled {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
            let startTime = dateFormatter.date(from: departuteTime)
            dateFormatter.dateFormat = "dd-MM-yyy HH:mm:ss"
            time += " ↖︎ " + dateFormatter.string(from: startTime ?? Date())
        }
        
        return time + "\t ✈︎ " + flightIata + "\n" + arrivalAirport + " (" + arrivalAirportIata + ")"
    }
    
    private func prepareDataForSecondaryText(departureFlight: Flights) -> String {
        guard var airline = departureFlight.airline?.name else { return "" }
        if airline == "empty" {
            airline = "private flight"
        }
        return airline
    }
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Update flights list")
        refreshControl?.addTarget(self, action: #selector(fecthDepartureFlightsFromNetwork), for: .valueChanged)
    }
    
    private func stopUpdateAnimation() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            if self.refreshControl != nil {
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    // Get data
    private func getDepartureFlights() {
        let currentDate = Date()
        guard let storageAirportIata = DataManager.storageAirportIata else {
            fecthDepartureFlightsFromNetwork()
            return
        }
        guard let storageDate = DataManager.storageDepartureDate else {
            fecthDepartureFlightsFromNetwork()
            return
        }
        if airportIata == storageAirportIata,
           DataManager.storageDepartureFlights,
           storageDate.distance(to: currentDate) < DataManager.storageTimeInterval {
            fecthDepartureFlightsFromStorage()
        } else {
            fecthDepartureFlightsFromNetwork()
        }
    }
    
    // Storage
    private func fecthDepartureFlightsFromStorage() {
        StorageManager.shared.fetchFlights(flightType: .departure) { result in
            switch result {
            case .success(let flights):
                self.departureFlights = []
                for flight in flights {
                    self.departureFlights.append(Flights(flightStatus: flight.flightStatus,
                                                       departure: DepartureAirport(airport: flight.departure?.airport,
                                                                                   iata: flight.departure?.iata,
                                                                                   scheduled: flight.departure?.scheduled),
                                                       arrival: ArrivalAirport(airport: flight.arrival?.airport,
                                                                               iata: flight.arrival?.iata,
                                                                               scheduled: flight.arrival?.scheduled),
                                                       airline: Airline(name: flight.airline?.name),
                                                       flight: Flight(iata: flight.flight?.iata)))
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        self.stopUpdateAnimation()
        tableView.reloadData()
    }
    
    
    // Network
    @objc private func fecthDepartureFlightsFromNetwork() {
        NetworkManager.shared.fetchFlights(from: .flightsUrl,
                                           key: .accessKey,
                                           type: .diparture,
                                           iata: airportIata) { result in
            switch result {
            case .success(let flights):
                self.departureFlights = flights
                self.stopUpdateAnimation()
                self.tableView.reloadData()
                DataManager.storageDepartureDate = Date()
                DataManager.storageDepartureFlights = true
                DataManager.storageAirportIata = self.airportIata
                StorageManager.shared.clearFlights(flightType: .departure)
                StorageManager.shared.saveFlights(flights: flights,
                                                  flightType: .departure)
            case .failure(_):
                self.stopUpdateAnimation()
                self.networkFailedAlert()
            }
        }
    }
    
    // Alerts
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
}

// MARK: - Extensions
extension DepartureTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterFlights(searchController.searchBar.text ?? "")
    }
    
    private func filterFlights(_ searchText: String) {
        filteredFlights = departureFlights.filter({ (flight: Flights) -> Bool in
            return (flight.arrival?.airport?.lowercased().contains(searchText.lowercased()) ?? false)
        })
        tableView.reloadData()
    }
}
