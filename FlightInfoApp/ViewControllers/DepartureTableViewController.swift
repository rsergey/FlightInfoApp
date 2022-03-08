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
    private let departureSearchController = UISearchController(searchResultsController: nil)
    private var departureFlights: [Flights] = []
    private var filteredFlights: [Flights] = []
    private var departureSearchBarIsEmpty: Bool {
        guard let text = departureSearchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        departureSearchController.isActive && !departureSearchBarIsEmpty
    }
    
    // MARK: - Override Methods
    override func viewDidLoad() {
        super.viewDidLoad()
//        tabBarController?.delegate = self
        
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        setupRefreshControl()
        getDepartureFlights()
        
        departureSearchController.searchResultsUpdater = self
        departureSearchController.obscuresBackgroundDuringPresentation = false
        departureSearchController.searchBar.placeholder = "Search departure flight"
        tabBarController?.navigationItem.searchController = departureSearchController
        definesPresentationContext = true
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        isFiltering ? filteredFlights.count : departureFlights.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "departureFlightCell", for: indexPath)
        let departureFlight = isFiltering ? filteredFlights[indexPath.row] : departureFlights[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = prepareDataForText(departureFlight: departureFlight)
        content.secondaryText = prepareDataForSecondaryText(departureFlight: departureFlight)
        cell.contentConfiguration = content
        return cell
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let flight = isFiltering ? filteredFlights[indexPath.row] : departureFlights[indexPath.row]
            
            guard let detailsVC = segue.destination as? DetailsTableViewController else { return }
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
        guard let key = KeychainManager.shared.readData(service: kSecAttributes.service.rawValue,
                                                        account: kSecAttributes.account.rawValue) else {
            self.stopUpdateAnimation()
            keychainFailedAlert()
            return
        }
        
        NetworkManager.shared.fetchFlights(from: .flightsUrl,
                                           key: key,
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

//extension DepartureTableViewController: UITabBarControllerDelegate {
//    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        if let selectedViewController = viewController as? DepartureTableViewController {
//            if selectedViewController.departureSearchController.isActive == true {
//                selectedViewController.departureSearchController.isActive = false
//                tableView.reloadData()
//            }
//        }
//    }
//}
