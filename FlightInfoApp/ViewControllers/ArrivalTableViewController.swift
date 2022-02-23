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
    private let arrivalSearchController = UISearchController(searchResultsController: nil)
    private var arrivalFlights: [Flights] = []
    private var filteredFlights: [Flights] = []
    private var searchBarIsEmpty: Bool {
        guard let text = arrivalSearchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return arrivalSearchController.isActive && !searchBarIsEmpty
    }
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        setupRefreshControl()
        getArrivalFlights()
        
        arrivalSearchController.searchResultsUpdater = self
        arrivalSearchController.obscuresBackgroundDuringPresentation = false
        arrivalSearchController.searchBar.placeholder = "Search flight"
        tabBarController?.navigationItem.searchController = arrivalSearchController
        definesPresentationContext = true
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredFlights.count : arrivalFlights.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "arrivalFlightCell", for: indexPath)
        let arrivalFlight = isFiltering ? filteredFlights[indexPath.row] : arrivalFlights[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = prepareDataForText(arrivalFlight: arrivalFlight)
        content.secondaryText = prepareDataForSecondaryText(arrivalFlight: arrivalFlight)
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let flight = isFiltering ? filteredFlights[indexPath.row] : arrivalFlights[indexPath.row]
            
            guard let detailsVC = segue.destination as? DetailsTableViewController else { return }
            detailsVC.flight = flight
        }
    }
    
    // MARK: - Private Methods
    
    // Interface
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
    
    private func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        refreshControl?.attributedTitle = NSAttributedString(string: "Update flights list")
        refreshControl?.addTarget(self, action: #selector(fecthArrivalFlightsFromNetwork), for: .valueChanged)
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
    private func getArrivalFlights() {
        let currentDate = Date()
        guard let storageAirportIata = DataManager.storageAirportIata else {
            fecthArrivalFlightsFromNetwork()
            return
        }
        guard let storageDate = DataManager.storageArrivalDate else {
            fecthArrivalFlightsFromNetwork()
            return
        }
        if airportIata == storageAirportIata,
           DataManager.storageArrivalFlights,
           storageDate.distance(to: currentDate) < DataManager.storageTimeInterval {
            fecthArrivalFlightsFromStorage()
        } else {
            fecthArrivalFlightsFromNetwork()
        }
    }
    
    // Storage
    private func fecthArrivalFlightsFromStorage() {
        StorageManager.shared.fetchFlights(flightType: .arrival) { result in
            switch result {
            case .success(let flights):
                self.arrivalFlights = []
                for flight in flights {
                    self.arrivalFlights.append(Flights(flightStatus: flight.flightStatus,
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
    @objc private func fecthArrivalFlightsFromNetwork() {
        guard let key = KeychainManager.shared.readData(service: kSecAttributes.service.rawValue,
                                                        account: kSecAttributes.account.rawValue) else {
            self.stopUpdateAnimation()
            keychainFailedAlert()
            return
        }
        
        NetworkManager.shared.fetchFlights(from: .flightsUrl,
                                           key: key,
                                           type: .arrival,
                                           iata: airportIata) { result in
            switch result {
            case .success(let flights):
                self.arrivalFlights = flights
                self.stopUpdateAnimation()
                self.tableView.reloadData()
                DataManager.storageArrivalDate = Date()
                DataManager.storageArrivalFlights = true
                DataManager.storageAirportIata = self.airportIata
                StorageManager.shared.clearFlights(flightType: .arrival)
                StorageManager.shared.saveFlights(flights: flights,
                                                  flightType: .arrival)
            case .failure(_):
                self.stopUpdateAnimation()
                self.networkFailedAlert()
            }
        }
    }
    
    // Alerts
    private func keychainFailedAlert() {
        let alert = UIAlertController(title: "No API key found!",
                                      message: "Please save your API key in the app settings.",
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",
                                     style: .default)
        alert.addAction(okAction)
        self.present(alert, animated: true)
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
